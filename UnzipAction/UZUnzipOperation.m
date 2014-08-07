//
//  UZUnzipOperation.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZUnzipOperation.h"
#import "UZNode.h"

NSString * const UZUnzipOperationErrorDomain = @"UZUnzipOperationErrorDomain";
const NSInteger UZUnzipOperationErrorCodeFailedToOpen = 1;
const NSInteger UZUnzipOperationErrorCodeFailedToWrite = 2;

@interface UZUnzipOperation ()
@property (nonatomic, strong, readonly) UZNode *node;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, strong, readonly) NSInputStream *stream;
@property (nonatomic, strong, readonly) NSURL *temporaryDirectoryURL;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSURL *fileURL;
@end

@implementation UZUnzipOperation

- (instancetype)initWithNode:(UZNode *)node
                    password:(NSString *)password
       temporaryDirectoryURL:(NSURL *)temporaryDirectoryURL
{
    NSParameterAssert(node);
    NSParameterAssert(temporaryDirectoryURL);
    
    if ((self = [super init])) {
        _node = node;
        _password = [password copy];
        _temporaryDirectoryURL = temporaryDirectoryURL;
        
        NSError *error = nil;
        NSInputStream *stream = [self.node streamWithPassword:_password error:&error];
        if (stream == nil) {
            self.error = error;
        } else {
            _stream = stream;
        }
    }
    return self;
}

- (void)main
{
    if (self.error != nil) return;
    
    @autoreleasepool {
        NSURL *subdirectoryURL = [self.temporaryDirectoryURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString] isDirectory:YES];
        NSURL *fileURL = [subdirectoryURL URLByAppendingPathComponent:self.node.fileName isDirectory:NO];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSError *error = nil;
        if (![fm createDirectoryAtURL:subdirectoryURL withIntermediateDirectories:YES attributes:nil error:&error]) {
            self.error = error;
            return;
        }
        
        FILE *fd = fopen(fileURL.path.UTF8String, "w");
        if (fd == NULL) {
            self.error = [NSError errorWithDomain:UZUnzipOperationErrorDomain code:UZUnzipOperationErrorCodeFailedToOpen userInfo:nil];
            return;
        }
        
        [self.stream open];
        
        NSUInteger totalBytesRead = 0;
        const NSUInteger totalSize = self.node.uncompressedSize;
        
        while (totalBytesRead < totalSize) {
            const NSUInteger remainingBytes = totalSize - totalBytesRead;
            uint8_t bytes[remainingBytes];
            NSInteger bytesRead = [self.stream read:bytes maxLength:remainingBytes];

            if (bytesRead > 0) {
                if (fwrite(bytes, sizeof(uint8_t), bytesRead, fd) == bytesRead) {
                    totalBytesRead += bytesRead;
                    
                    if (self.progressHandler != nil) {
                        self.progressHandler((float)totalBytesRead / totalSize);
                    }
                } else {
                    self.error = [NSError errorWithDomain:UZUnzipOperationErrorDomain code:UZUnzipOperationErrorCodeFailedToWrite userInfo:nil];
                    break;
                }
            } else {
                self.error = self.stream.streamError;
                break;
            }
        }
        
        if (self.error == nil) {
            self.fileURL = fileURL;
        } else {
            [fm removeItemAtURL:fileURL error:nil];
        }
        
        [self.stream close];
        fclose(fd);
    }
}

@end
