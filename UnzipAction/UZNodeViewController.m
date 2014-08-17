//
//  UZNodeViewController.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZNodeViewController.h"
#import "UZNodeViewControllerSubclass.h"
#import "UZNodeTableViewCell.h"
#import "UZPreviewViewController.h"
#import "UZNode.h"
#import "UZUnzipCoordinator.h"
#import "UZGlyphFactory.h"

const CGFloat kSearchBarHeight = 44.0;

@interface UZNodeViewController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong, readonly) UILocalizedIndexedCollation *collation;
@property (nonatomic, strong, readonly) NSByteCountFormatter *byteCountFormatter;

@property (nonatomic, weak, readonly) UZNodeViewController *parentNodeViewController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign, readonly, getter=isSearchResultsController) BOOL searchResultsController;
@property (nonatomic, assign, readonly, getter=isSearching) BOOL searching;
@property (nonatomic, strong) NSString *previousSearchQuery;
@property (nonatomic, strong) NSArray *filteredResults;
@end

static NSArray * SectionsForNode(NSArray *children, UILocalizedIndexedCollation *collation)
{
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    const SEL stringSelector = @selector(fileName);
    const NSUInteger titleCount = collation.sectionIndexTitles.count;
    
    for (NSUInteger i = 0; i < titleCount; i++) {
        [sections addObject:[[NSMutableArray alloc] init]];
    }
    
    for (UZNode *child in children) {
        NSInteger sectionIndex = [collation sectionForObject:child collationStringSelector:stringSelector];
        [sections[sectionIndex] addObject:child];
    }
    
    for (NSUInteger i = 0; i < titleCount; i++) {
        NSArray *sortedChildren = [collation sortedArrayFromArray:sections[i] collationStringSelector:stringSelector];
        [sections replaceObjectAtIndex:i withObject:sortedChildren];
    }
    
    return sections;
}

static NSPredicate * FilterPredicate(NSString *searchQuery)
{
    return [NSPredicate predicateWithBlock:^BOOL(UZNode *node, NSDictionary *bindings) {
        NSRange range = [node.fileName rangeOfString:searchQuery options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
        return (range.location != NSNotFound);
    }];
}

static NSArray * FilteredChildren(NSArray *children, NSString *searchQuery)
{
    return [children filteredArrayUsingPredicate:FilterPredicate(searchQuery)];
}

@implementation UZNodeViewController

- (instancetype)initWithRootNode:(UZNode *)rootNode
                unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
                extensionContext:(NSExtensionContext *)extensionContext
{
    return [self initWithRootNode:rootNode unzipCoordinator:unzipCoordinator extensionContext:extensionContext parentNodeViewController:nil];
}

- (instancetype)initWithRootNode:(UZNode *)rootNode
                unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
                extensionContext:(NSExtensionContext *)extensionContext
        parentNodeViewController:(UZNodeViewController *)parentNodeViewController
{
    if ((self = [self initWithStyle:UITableViewStylePlain extensionContext:extensionContext parentNodeViewController:parentNodeViewController])) {
        self.unzipCoordinator = unzipCoordinator;
        self.rootNode = rootNode;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
             extensionContext:(NSExtensionContext *)extensionContext
     parentNodeViewController:(UZNodeViewController *)parentNodeViewController
{
    if ((self = [super initWithStyle:style extensionContext:extensionContext])) {
        _parentNodeViewController = parentNodeViewController;
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
    _byteCountFormatter = [[NSByteCountFormatter alloc] init];
    self.definesPresentationContext = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = UIColor.whiteColor;
    self.tableView.backgroundView = backgroundView;
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(UZNodeTableViewCell.class) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:UZNodeTableViewCell.reuseIdentifier];
    self.tableView.rowHeight = UZNodeTableViewCell.rowHeight;
    
    [self configureAndDisplaySearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.searchController != nil) {
        self.tableView.contentOffset = (CGPoint){ .y = kSearchBarHeight };
    }
}

#pragma mark - Accessors

- (void)setRootNode:(UZNode *)rootNode
{
    if (_rootNode != rootNode) {
        self.searchController = nil;
        
        _rootNode = rootNode;
        
        if (![self isSearchResultsController]) {
            [self createSearchController];
        }
        
        self.navigationItem.title = _rootNode.fileName;
        [self rebuildSections];
    }
}

- (void)setSearchQuery:(NSString *)searchQuery
{
    if (_searchQuery != searchQuery) {
        if (searchQuery.length) {
            self.previousSearchQuery = _searchQuery;
        } else {
            self.previousSearchQuery = nil;
        }
        
        _searchQuery = searchQuery;
        [self rebuildSections];
    }
}

- (BOOL)isSearching
{
    return (self.searchQuery.length != 0);
}

+ (NSSet *)keyPathsForValuesAffectingSearching
{
    return [NSSet setWithObject:@"searchQuery"];
}

- (BOOL)isSearchResultsController
{
    return (self.parentNodeViewController != nil);
}

+ (NSSet *)keyPathsForValuesAffectingSearchResultsController
{
    return [NSSet setWithObject:@"parentNodeViewController"];
}

#pragma mark - UITableViewDataSource

- (UZNode *)nodeAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *children = self.sections[indexPath.section];
    return children[indexPath.row];
}

- (void)rebuildSections
{
    NSArray *children = nil;
    if (self.searching) {
        if (self.previousSearchQuery != nil && [self.searchQuery hasPrefix:self.previousSearchQuery]) {
            children = FilteredChildren(self.filteredResults, self.searchQuery);
        } else {
            children = FilteredChildren(self.rootNode.children, self.searchQuery);
            self.filteredResults = children;
        }
    } else {
        children = self.rootNode.children;
        self.filteredResults = nil;
    }
    
    self.sections = SectionsForNode(children, self.collation);
    [self.tableView reloadData];
}

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
    UZNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UZNodeTableViewCell.reuseIdentifier];
    UZNode *node = [self nodeAtIndexPath:indexPath];
    
    cell.fileNameLabel.text = node.fileName;
    if (node.directory) {
        cell.fileNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.fileSizeLabel.text = nil;
        cell.glyphImageView.image = UZDirectoryGlyphImage(nil);
    } else {
        cell.fileNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.fileSizeLabel.text = [self.byteCountFormatter stringFromByteCount:node.uncompressedSize];
        cell.glyphImageView.image = UZFileGlyphImage(node.fileName, UIColor.blueColor);
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UZNode *node = [self nodeAtIndexPath:indexPath];
    if (node.directory) {
        UZNodeViewController *viewController = [[self.class alloc] initWithRootNode:node unzipCoordinator:self.unzipCoordinator extensionContext:self.uz_extensionContext];
        [self pushViewController:viewController animated:YES];
    } else if (node.encrypted) {
        [self presentPasswordAlertForNode:node completionHandler:^(NSString *password) {
            if (password != nil) {
                [self pushPreviewControllerWithNode:node password:password];
            }
        }];
    } else {
        [self pushPreviewControllerWithNode:node password:nil];
    }
}

- (void)pushPreviewControllerWithNode:(UZNode *)node password:(NSString *)password
{
    UZPreviewViewController *viewController = [[UZPreviewViewController alloc] initWithNode:node password:password unzipCoordinator:self.unzipCoordinator extensionContext:self.uz_extensionContext];
    [self pushViewController:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UINavigationController *navigationController = self.navigationController ?: self.parentNodeViewController.navigationController;
    [navigationController pushViewController:viewController animated:animated];
}

#pragma mark - Search

- (void)createSearchController
{
    UZNodeViewController *searchResultsController = [[UZNodeViewController alloc] initWithRootNode:_rootNode unzipCoordinator:self.unzipCoordinator extensionContext:nil parentNodeViewController:self];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchResultsUpdater = searchResultsController;
    [self configureAndDisplaySearchBar];
}

- (void)configureAndDisplaySearchBar
{
    if (self.tableView.tableHeaderView != nil || self.searchController == nil) return;
    
    UISearchBar *searchBar = self.searchController.searchBar;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    CGRect searchBarFrame = searchBar.frame;
    searchBarFrame.size.height = kSearchBarHeight;
    searchBar.frame = searchBarFrame;
    
    self.tableView.tableHeaderView = searchBar;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    UZNodeViewController *viewController = (UZNodeViewController *)searchController.searchResultsController;
    viewController.searchQuery = searchController.searchBar.text;
}

#pragma mark - Encryption

- (void)presentPasswordAlertForNode:(UZNode *)node completionHandler:(void (^)(NSString *password))completionHandler
{
    NSParameterAssert(completionHandler);
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"EncryptionAlertMessage", nil), node.fileName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"EncryptionAlertTitle", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.secureTextEntry = YES;
    }];
    
    __weak UIAlertController *weakAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler([weakAlert.textFields[0] text]);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
