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
@property (nonatomic, assign, readonly, getter=isEncrypted) BOOL encrypted;
@property (nonatomic, assign, readonly) NSUInteger uncompressedSize;
@property (nonatomic, copy, readonly) NSString *fileName;

+ (instancetype)nodeWithArchive:(ZZArchive *)archive;

- (NSInputStream *)streamWithPassword:(NSString *)password error:(NSError **)error;

@end
