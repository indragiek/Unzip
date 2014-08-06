//
//  UZNode.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZArchiveEntry;
@class ZZArchive;

@interface UZNode : NSObject

@property (nonatomic, strong, readonly) NSArray *children;
@property (nonatomic, assign, readonly, getter=isDirectory) BOOL directory;
@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) ZZArchiveEntry *archiveEntry;

+ (instancetype)nodeWithArchive:(ZZArchive *)archive;

@end
