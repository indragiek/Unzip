//
//  UZNodeViewController.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZNodeViewController.h"
#import "UZNode.h"

@interface UZNodeViewController ()
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong, readonly) UILocalizedIndexedCollation *collation;
@end

static NSArray * SectionsForNode(UZNode *node, UILocalizedIndexedCollation *collation)
{
    NSMutableDictionary *sections = [[NSMutableDictionary alloc] init];
    const SEL stringSelector = @selector(fileName);
    
    for (UZNode *child in node.children) {
        NSInteger section = [collation sectionForObject:child collationStringSelector:stringSelector];
        NSMutableArray *children = sections[@(section)];
        if (children == nil) {
            children = [[NSMutableArray alloc] init];
            sections[@(section)] = children;
        }
        [children addObject:child];
    }
    
    NSArray *sortedKeys = [sections.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *sortedSections = [[NSMutableArray alloc] init];
    for (NSNumber *sectionIndex in sortedKeys) {
        NSArray *sortedChildren = [collation sortedArrayFromArray:sections[sectionIndex] collationStringSelector:stringSelector];
        [sortedSections addObject:sortedChildren];
    }
    return sortedSections;
}

@implementation UZNodeViewController

- (instancetype)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style])) {
        [self commonInit_UZNodeViewController];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self commonInit_UZNodeViewController];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit_UZNodeViewController];
    }
    return self;
}

- (void)commonInit_UZNodeViewController
{
    _collation = UILocalizedIndexedCollation.currentCollation;
}

#pragma mark - Accessors

- (void)setRootNode:(UZNode *)rootNode
{
    if (_rootNode != rootNode) {
        _rootNode = rootNode;
        
        self.navigationItem.title = _rootNode.fileName;
        self.sections = SectionsForNode(_rootNode, self.collation);
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.collation.sectionTitles[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.collation.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.collation sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"NodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    NSArray *children = self.sections[indexPath.section];
    UZNode *node = children[indexPath.row];
    
    cell.textLabel.text = node.fileName;
    return cell;
}

@end
