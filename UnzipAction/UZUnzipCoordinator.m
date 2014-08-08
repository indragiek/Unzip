//
//  UZUnzipCoordinator.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZUnzipCoordinator.h"
#import "UZUnzipOperation.h"
#import "UZNode.h"

@interface UZUnzipCoordinator ()
@property (nonatomic, strong, readonly) ZZArchive *archive;
@property (nonatomic, strong, readonly) NSURL *temporaryDirectoryURL;
@property (nonatomic, strong, readonly) NSMutableDictionary *unarchivedURLs;
@property (nonatomic, strong, readonly) NSMutableDictionary *operationSubscribers;
@property (nonatomic, strong, readonly) NSMutableSet *nodesForInProgressOperations;
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) dispatch_queue_t stateQueue;
@end

@interface UZUnzipOperationSubscriber : NSObject
@property (nonatomic, copy, readonly) void (^progressHandler)(float);
@property (nonatomic, copy, readonly) void (^completionHandler)(NSURL *, NSError *);
@end

@implementation UZUnzipOperationSubscriber

- (instancetype)initWithProgressHandler:(void (^)(float progress))progressHandler completionHandler:(void (^)(NSURL *fileURL, NSError *error))completionHandler
{
    if ((self = [super init])) {
        _progressHandler = [progressHandler copy];
        _completionHandler = [completionHandler copy];
    }
    return self;
}

@end

@interface UZUnzipOperationToken ()
@property (nonatomic, strong, readonly) UZNode *node;
@property (nonatomic, strong, readonly) UZUnzipOperationSubscriber *subscriber;
@end

@implementation UZUnzipOperationToken

- (instancetype)initWithNode:(UZNode *)node subscriber:(UZUnzipOperationSubscriber *)subscriber
{
    if ((self = [super init])) {
        _node = node;
        _subscriber = subscriber;
    }
    return self;
}

@end

@implementation UZUnzipCoordinator

- (instancetype)initWithArchive:(ZZArchive *)archive
{
    if ((self = [super init])) {
        _archive = archive;
        _temporaryDirectoryURL = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        _unarchivedURLs = [[NSMutableDictionary alloc] init];
        _operationSubscribers = [[NSMutableDictionary alloc] init];
        _nodesForInProgressOperations = [[NSMutableSet alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        _stateQueue = dispatch_queue_create("com.indragie.UZUnzipCoordinator.StateQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtURL:_temporaryDirectoryURL error:nil];
}

- (UZUnzipOperationToken *)unzipNode:(UZNode *)node
                            password:(NSString *)password
                     progressHandler:(void (^)(float progress))progressHandler
                   completionHandler:(void (^)(NSURL *fileURL, NSError *error))completionHandler
{
    NSURL *fileURL = [self fileURLForNode:node];
    if (fileURL != nil) {
        if (completionHandler) {
            completionHandler(fileURL, nil);
        }
        return nil;
    }
    
    UZUnzipOperationSubscriber *subscriber = [[UZUnzipOperationSubscriber alloc] initWithProgressHandler:progressHandler completionHandler:completionHandler];
    [self addSubscriber:subscriber forNode:node];
    
    UZUnzipOperationToken *token = [[UZUnzipOperationToken alloc] initWithNode:node subscriber:subscriber];
    if ([self isOperationInProgressForNode:node]) return token;
    
    UZUnzipOperation *operation = [[UZUnzipOperation alloc] initWithNode:node password:password temporaryDirectoryURL:self.temporaryDirectoryURL];
    
    operation.progressHandler = ^(float progress) {
        NSArray *subscribers = [self subscribersForNode:node];
        for (UZUnzipOperationSubscriber *subscriber in subscribers) {
            if (subscriber.progressHandler) {
                subscriber.progressHandler(progress);
            }
        }
    };
    
    __weak UZUnzipOperation *weakOperation = operation;
    operation.completionBlock = ^{
        NSArray *subscribers = [self subscribersForNode:node];
        for (UZUnzipOperationSubscriber *subscriber in subscribers) {
            if (subscriber.completionHandler) {
                subscriber.completionHandler(weakOperation.fileURL, weakOperation.error);
            }
        }
        [self setFileURL:weakOperation.fileURL forNode:node];
        [self setOperationInProgress:NO forNode:node];
    };
    
    [self.operationQueue addOperation:operation];
    [self setOperationInProgress:YES forNode:node];
    
    return token;
}

- (void)cancelUnzipOperationWithToken:(UZUnzipOperationToken *)token
{
    if (token == nil) return;
    
    [self removeSubscriber:token.subscriber forNode:token.node];
    if ([self subscribersForNode:token.node].count == 0) {
        for (UZUnzipOperation *operation in self.operationQueue.operations) {
            if ([operation.node isEqual:token.node]) {
                [operation cancel];
            }
        }
    }
}

#pragma mark - Private

- (void)setFileURL:(NSURL *)URL forNode:(UZNode *)node
{
    dispatch_barrier_async(self.stateQueue, ^{
        self.unarchivedURLs[node.fileName] = URL;
    });
}

- (NSURL *)fileURLForNode:(UZNode *)node
{
    __block NSURL *URL = nil;
    dispatch_sync(self.stateQueue, ^{
        URL = self.unarchivedURLs[node.fileName];
    });
    return URL;
}

- (void)addSubscriber:(UZUnzipOperationSubscriber *)subscriber forNode:(UZNode *)node
{
    dispatch_barrier_async(self.stateQueue, ^{
        NSMutableArray *subscribers = self.operationSubscribers[node.fileName];
        if (subscribers == nil) {
            subscribers = [[NSMutableArray alloc] init];
            self.operationSubscribers[node.fileName] = subscribers;
        }
        [subscribers addObject:subscriber];
    });
}

- (NSArray *)subscribersForNode:(UZNode *)node
{
    __block NSArray *subscribers = nil;
    dispatch_sync(self.stateQueue, ^{
        subscribers = self.operationSubscribers[node.fileName];
    });
    return subscribers ?: @[];
}

- (void)removeAllSubscribersForNode:(UZNode *)node
{
    dispatch_barrier_async(self.stateQueue, ^{
        [self.operationSubscribers removeObjectForKey:node.fileName];
    });
}

- (void)removeSubscriber:(UZUnzipOperationSubscriber *)subscriber forNode:(UZNode *)node
{
    dispatch_barrier_async(self.stateQueue, ^{
        NSMutableArray *subscribers = self.operationSubscribers[node.fileName];
        [subscribers removeObject:subscriber];
    });
}

- (void)setOperationInProgress:(BOOL)operationInProgress forNode:(UZNode *)node
{
    dispatch_barrier_async(self.stateQueue, ^{
        if (operationInProgress) {
            [self.nodesForInProgressOperations addObject:node];
        } else {
            [self.nodesForInProgressOperations removeObject:node];
        }
    });
}

- (BOOL)isOperationInProgressForNode:(UZNode *)node
{
    __block BOOL operationInProgress = NO;
    dispatch_sync(self.stateQueue, ^{
        operationInProgress = [self.nodesForInProgressOperations containsObject:node];
    });
    return operationInProgress;
}

@end
