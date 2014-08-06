//
//  UZUnzipOperation.h
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UZNode;

@interface UZUnzipOperation : NSOperation

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) NSURL *fileURL;

- (instancetype)initWithNode:(UZNode *)node
                    password:(NSString *)password
       temporaryDirectoryURL:(NSURL *)temporaryDirectoryURL;

@end
