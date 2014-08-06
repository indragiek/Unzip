//
//  UZUnzipOperation.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZUnzipOperation.h"
#import "UZNode.h"

@interface UZUnzipOperation ()
@property (nonatomic, strong, readonly) UZNode *node;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, strong, readonly) NSURL *temporaryDirectoryURL;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSURL *fileURL;
@end

@implementation UZUnzipOperation

- (instancetype)initWithNode:(UZNode *)node
                    password:(NSString *)password
       temporaryDirectoryURL:(NSURL *)temporaryDirectoryURL
{
    if ((self = [super init])) {
        _node = node;
        _password = [password copy];
        _temporaryDirectoryURL = temporaryDirectoryURL;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        NSError *error = nil;
        NSInputStream *stream = [self.node streamWithPassword:self.password error:&error];
        if (stream == nil) {
            self.error = error;
            return;
        }
        
        NSURL *subdirectoryURL = [self.temporaryDirectoryURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString] isDirectory:YES];
        NSURL *fileURL = [subdirectoryURL URLByAppendingPathComponent:self.node.fileName isDirectory:NO];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        if (![fm createDirectoryAtURL:subdirectoryURL withIntermediateDirectories:YES attributes:nil error:&error]) {
            self.error = error;
            return;
        }
        
        if (![fm createFileAtPath:fileURL.path contents:[NSData data] attributes:nil]) {
            self.error = error;
            return;
        }
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
        if (fileHandle == nil) {
            self.error = error;
            return;
        }
        
        [stream open];
        
        NSUInteger totalBytesRead = 0;
        const NSUInteger totalSize = self.node.uncompressedSize;
        
        while (totalBytesRead < totalSize) {
            const NSUInteger remainingBytes = totalSize - totalBytesRead;
            uint8_t bytes[remainingBytes];
            NSInteger bytesRead = [stream read:bytes maxLength:remainingBytes];

            if (bytesRead > 0) {
                [fileHandle writeData:[NSData dataWithBytesNoCopy:bytes length:bytesRead]];
                totalBytesRead += bytesRead;
            } else {
                break;
            }
        }
        if (stream.streamError) {
            self.error = stream.streamError;
        } else {
            self.fileURL = fileURL;
        }
        
        [stream close];
    }
}

@end
