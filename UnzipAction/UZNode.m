//
//  UZNode.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZNode.h"

#import <zipzap/zipzap.h>

@interface UZNodeEntryContainer : NSObject
@property (nonatomic, strong) ZZArchiveEntry *entry;
@property (nonatomic, strong, readonly) NSMutableArray *mutableChildren;
@end

@implementation UZNodeEntryContainer

- (instancetype)initWithEntry:(ZZArchiveEntry *)entry
{
    if ((self = [super init])) {
        _entry = entry;
        _mutableChildren = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@interface UZNode ()
- (instancetype)initWithEntry:(ZZArchiveEntry *)entry level:(NSUInteger)level children:(NSArray *)children;
@property (nonatomic, strong, readonly) ZZArchiveEntry *archiveEntry;
@end

static BOOL EntryIsDirectory(ZZArchiveEntry *entry)
{
    return (entry.uncompressedSize == 0) && !entry.compressed;
}

static NSArray * IgnoredFilenames()
{
    static NSArray *filenames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        filenames = @[@"__MACOSX",
                      @".DS_Store"];
    });
    return filenames;
}

static UZNode *NodeForEntries(NSArray *entries, ZZArchiveEntry *parent, NSUInteger level)
{
    NSArray *ignoredFilenames = IgnoredFilenames();
    NSMutableDictionary *nameToEntryContainerMapping = [[NSMutableDictionary alloc] init];
    NSMutableArray *containers = [[NSMutableArray alloc] init];
    
    for (ZZArchiveEntry *entry in entries) {
        NSArray *components = entry.fileName.pathComponents;
        if (components.count == 0) continue;
        
        NSString *fileName = components[level];
        if ([ignoredFilenames containsObject:fileName]) continue;
        
        UZNodeEntryContainer *container = nameToEntryContainerMapping[fileName];
        if (container == nil) {
            container = [[UZNodeEntryContainer alloc] initWithEntry:entry];
            nameToEntryContainerMapping[fileName] = container;
            [containers addObject:container];
        } else {
            [container.mutableChildren addObject:entry];
        }
    }
    
    NSMutableArray *children = [[NSMutableArray alloc] init];
    for (UZNodeEntryContainer *container in containers) {
        UZNode *node = NodeForEntries(container.mutableChildren, container.entry, level + 1);
        [children addObject:node];
    }
    
    return [[UZNode alloc] initWithEntry:parent level:level children:children];
}

static NSString * IndentationString(NSUInteger level)
{
    NSMutableString *string = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < level; i++) {
        [string appendString:@"----"];
    }
    return string;
}

static void PrintPrettyHierarchicalRepresentation(UZNode *node, NSMutableString *string, NSUInteger level)
{
    if (node.fileName.length != 0) {
        [string appendString:IndentationString(level)];
        [string appendFormat:@" %@\n", node.fileName];
    }
    
    for (UZNode *child in node.children) {
        PrintPrettyHierarchicalRepresentation(child, string, level + 1);
    }
}

@implementation UZNode

- (instancetype)initWithEntry:(ZZArchiveEntry *)entry level:(NSUInteger)level children:(NSArray *)children
{
    if ((self = [super init])) {
        _directory = EntryIsDirectory(entry);
        _encrypted = entry.encrypted;
        if (level >= 1) {
            _fileName = entry.fileName.pathComponents[level - 1];
        }
        _children = children;
        _archiveEntry = entry;
    }
    return self;
}

+ (instancetype)nodeWithArchive:(ZZArchive *)archive
{
    return NodeForEntries(archive.entries, nil, 0);
}

#pragma mark - NSObject

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] init];
    PrintPrettyHierarchicalRepresentation(self, description, 0);
    return description;
}

@end
