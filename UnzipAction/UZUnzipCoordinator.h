//
//  UZUnzipCoordinator.h
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZArchive;
@class UZNode;

@interface UZUnzipCoordinator : NSObject

- (instancetype)initWithArchive:(ZZArchive *)archive;

- (void)unzipNode:(UZNode *)node password:(NSString *)password progressHandler:(void (^)(float progress))progressHandler completionHandler:(void (^)(NSURL *fileURL, NSError *error))completionHandler;

@end
