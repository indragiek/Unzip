//
//  UZPreviewViewController.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZPreviewViewController.h"
#import "UZNode.h"
#import "UZUnzipCoordinator.h"

#import <QuickLook/QuickLook.h>

@interface UZPreviewItem : NSObject <QLPreviewItem>
@property (nonatomic, strong, readonly) NSURL *fileURL;
@end

@interface UZPreviewViewController () <QLPreviewControllerDataSource>
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, strong, readonly) UZNode *node;
@property (nonatomic, strong, readwrite) UZUnzipCoordinator *unzipCoordinator;
@property (nonatomic, strong) UZPreviewItem *previewItem;
@property (nonatomic, strong) QLPreviewController *previewController;

@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@end

@implementation UZPreviewItem

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    if ((self = [super init])) {
        _fileURL = fileURL;
    }
    return self;
}

#pragma mark - QLPreviewItem

- (NSURL *)previewItemURL
{
    return self.fileURL;
}

@end

@implementation UZPreviewViewController

#pragma mark - Lifecycle

- (instancetype)initWithNode:(UZNode *)node
                    password:(NSString *)password
            unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
            extensionContext:(NSExtensionContext *)extensionContext
{
    if ((self = [super initWithExtensionContext:extensionContext])) {
        _node = node;
        _password = [password copy];
        _unzipCoordinator = unzipCoordinator;
        
        self.navigationItem.title = node.fileName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.progressLabel.text = self.node.fileName;
    [self.unzipCoordinator unzipNode:self.node password:self.password progressHandler:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    } completionHandler:^(NSURL *fileURL, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self showQuickLookPreviewWithURL:fileURL];
            } else {
                NSLog(@"%@", error);
            }
        });
    }];
}

- (void)showQuickLookPreviewWithURL:(NSURL *)fileURL
{
    self.previewItem = [[UZPreviewItem alloc] initWithFileURL:fileURL];
    self.previewController = [[QLPreviewController alloc] init];
    self.previewController.dataSource = self;
    [self.previewController reloadData];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _previewController.view.frame = self.view.bounds;
}

#pragma mark - Accessors

- (void)setPreviewController:(QLPreviewController *)previewController
{
    if (_previewController != previewController) {
        [_previewController willMoveToParentViewController:nil];
        [_previewController.view removeFromSuperview];
        [_previewController removeFromParentViewController];
        
        _previewController = previewController;
        
        [self addChildViewController:_previewController];
        [self.view addSubview:_previewController.view];
        [_previewController didMoveToParentViewController:self];
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.previewItem;
}

@end
