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
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    const SEL stringSelector = @selector(fileName);
    const NSUInteger titleCount = collation.sectionIndexTitles.count;
    
    for (NSUInteger i = 0; i < titleCount; i++) {
        [sections addObject:[[NSMutableArray alloc] init]];
    }
    
    for (UZNode *child in node.children) {
        NSInteger sectionIndex = [collation sectionForObject:child collationStringSelector:stringSelector];
        [sections[sectionIndex] addObject:child];
    }
    
    for (NSUInteger i = 0; i < titleCount; i++) {
        NSArray *sortedChildren = [collation sortedArrayFromArray:sections[i] collationStringSelector:stringSelector];
        [sections replaceObjectAtIndex:i withObject:sortedChildren];
    }
    
    return sections;
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
    if ([self.sections[section] count] != 0) {
        return self.collation.sectionTitles[section];
    }
    return nil;
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
    
    UZNode *node = [self nodeAtIndexPath:indexPath];
    
    cell.textLabel.text = node.fileName;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UZNodeViewController *controller = [[self.class alloc] init];
    controller.rootNode = [self nodeAtIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private

- (UZNode *)nodeAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *children = self.sections[indexPath.section];
    return children[indexPath.row];
}

@end
