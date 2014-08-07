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
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;
@end

@implementation UZUnzipCoordinator

- (instancetype)initWithArchive:(ZZArchive *)archive
{
    if ((self = [super init])) {
        _archive = archive;
        _temporaryDirectoryURL = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        _unarchivedURLs = [[NSMutableDictionary alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtURL:_temporaryDirectoryURL error:nil];
}

- (void)unzipNode:(UZNode *)node password:(NSString *)password progressHandler:(void (^)(float progress))progressHandler completionHandler:(void (^)(NSURL *fileURL, NSError *error))completionHandler
{
    NSURL *fileURL = [self fileURLForNode:node];
    if (fileURL != nil) {
        if (completionHandler) {
            completionHandler(fileURL, nil);
        }
        return;
    }
    
    UZUnzipOperation *operation = [[UZUnzipOperation alloc] initWithNode:node password:password temporaryDirectoryURL:self.temporaryDirectoryURL];
    operation.progressHandler = progressHandler;
    
    __weak UZUnzipOperation *weakOperation = operation;
    operation.completionBlock = ^{
        if (completionHandler) {
            completionHandler(weakOperation.fileURL, weakOperation.error);
        }
        [self setFileURL:weakOperation.fileURL forNode:node];
    };
    [self.operationQueue addOperation:operation];
}

#pragma mark - Private

- (void)setFileURL:(NSURL *)URL forNode:(UZNode *)node
{
    @synchronized(self) {
        _unarchivedURLs[node.fileName] = URL;
    }
}

- (NSURL *)fileURLForNode:(UZNode *)node
{
    @synchronized(self) {
        return _unarchivedURLs[node.fileName];
    }
}

@end
