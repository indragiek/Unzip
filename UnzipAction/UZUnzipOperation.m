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
    if (self.error) return;
    
    @autoreleasepool {
        NSURL *subdirectoryURL = [self.temporaryDirectoryURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString] isDirectory:YES];
        NSURL *fileURL = [subdirectoryURL URLByAppendingPathComponent:self.node.fileName isDirectory:NO];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSError *error = nil;
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
        
        [self.stream open];
        
        NSUInteger totalBytesRead = 0;
        const NSUInteger totalSize = self.node.uncompressedSize;
        
        while (totalBytesRead < totalSize) {
            const NSUInteger remainingBytes = totalSize - totalBytesRead;
            uint8_t bytes[remainingBytes];
            NSInteger bytesRead = [self.stream read:bytes maxLength:remainingBytes];

            if (bytesRead > 0) {
                [fileHandle writeData:[NSData dataWithBytesNoCopy:bytes length:bytesRead]];
                totalBytesRead += bytesRead;
                
                if (self.progressHandler != nil) {
                    self.progressHandler((float)totalBytesRead / totalSize);
                }
            } else {
                break;
            }
        }
        
        NSError *streamError = self.stream.streamError;
        if (streamError != nil) {
            self.error = streamError;
        } else {
            self.fileURL = fileURL;
        }
        [self.stream close];
    }
}

@end
