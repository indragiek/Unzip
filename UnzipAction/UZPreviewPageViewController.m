//
//  UZPreviewPageViewController.m
//  Unzip
//
//  Created by Indragie on 8/8/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZPreviewPageViewController.h"
#import "UZPreviewViewController.h"
#import "UZNode.h"
#import <objc/runtime.h>

static void * kUZPreviewIndexKey = &kUZPreviewIndexKey;

@interface UZPreviewViewController (UZIndexing)
@property (nonatomic, assign) NSUInteger uz_index;
@end

@implementation UZPreviewViewController (UZIndexing)

- (NSUInteger)uz_index
{
    return [objc_getAssociatedObject(self, kUZPreviewIndexKey) unsignedIntegerValue];
}

- (void)setUz_index:(NSUInteger)uz_index
{
    objc_setAssociatedObject(self, kUZPreviewIndexKey, @(uz_index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface UZPreviewPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong, readonly) NSExtensionContext *uz_extensionContext;
@property (nonatomic, strong, readwrite) UZUnzipCoordinator *unzipCoordinator;
@property (nonatomic, strong, readonly) NSArray *unencryptedChildren;
@property (nonatomic, assign) NSUInteger startingIndex;
@end

@implementation UZPreviewPageViewController
@synthesize uz_extensionContext = _uz_extensionContext;

#pragma mark - Lifecycle

- (instancetype)initWithRootNode:(UZNode *)rootNode
               startingChildNode:(UZNode *)startingChildNode
                unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
                extensionContext:(NSExtensionContext *)extensionContext
{
    if ((self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil])) {
        self.dataSource = self;
        self.delegate = self;
        
        _uz_extensionContext = extensionContext;
        _unzipCoordinator = unzipCoordinator;
        _unencryptedChildren = [rootNode.children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UZNode *child, NSDictionary *bindings) {
            return !child.encrypted;
        }]];
        _startingIndex = [_unencryptedChildren indexOfObject:startingChildNode];
        
        UZPreviewViewController *viewController = [self previewViewControllerForNodeAtIndex:_startingIndex];
        [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.uz_extensionContext != nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UZPreviewViewController *)previewViewControllerForNodeAtIndex:(NSUInteger)index
{
    UZPreviewViewController *viewController = [[UZPreviewViewController alloc] initWithNode:self.unencryptedChildren[index] password:nil unzipCoordinator:self.unzipCoordinator extensionContext:self.uz_extensionContext];
    viewController.uz_index = index;
    return viewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UZPreviewViewController *)viewController
{
    return [self previewViewControllerForNodeAtIndex:viewController.uz_index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UZPreviewViewController *)viewController
{
    return [self previewViewControllerForNodeAtIndex:viewController.uz_index + 1];
}

#pragma mark - Extension Context

- (NSExtensionContext *)uz_extensionContext
{
    return self.extensionContext ?: _uz_extensionContext;
}

+ (NSSet *)keyPathsForValuesAffectingUz_extensionContext
{
    return [NSSet setWithObject:@"extensionContext"];
}

- (void)close
{
    [self.uz_extensionContext completeRequestReturningItems:self.uz_extensionContext.inputItems completionHandler:nil];
}

@end
