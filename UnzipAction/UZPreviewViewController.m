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
#import "UZOpenInActivity.h"

#import <QuickLook/QuickLook.h>

@interface UZQuickLookPreviewItem : NSObject <QLPreviewItem>
@property (nonatomic, strong, readonly) NSURL *fileURL;
@end

@interface UZPreviewViewController () <QLPreviewControllerDataSource>
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, strong, readonly) UZNode *node;
@property (nonatomic, strong, readonly) UZUnzipCoordinator *unzipCoordinator;
@property (nonatomic, strong) UZUnzipOperationToken *unzipToken;
@property (nonatomic, strong) UZQuickLookPreviewItem *previewItem;
@property (nonatomic, strong) QLPreviewController *previewController;

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@end

@implementation UZQuickLookPreviewItem

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.previewController != nil) return;
    
    self.unzipToken = [self.unzipCoordinator unzipNode:self.node password:self.password progressHandler:^(float progress) {
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.unzipCoordinator cancelUnzipOperationWithToken:self.unzipToken];
    self.unzipToken = nil;
}

- (void)showQuickLookPreviewWithURL:(NSURL *)fileURL
{
    self.previewItem = [[UZQuickLookPreviewItem alloc] initWithFileURL:fileURL];
    self.previewController = [[QLPreviewController alloc] init];
    self.previewController.dataSource = self;
    [self.previewController reloadData];
}

#pragma mark - Actions

- (IBAction)performAction:(id)sender
{
    if (self.previewItem == nil) return;
    
    UZOpenInActivity *openInActivity = [[UZOpenInActivity alloc] initWithBarButtonItem:sender];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.previewItem.fileURL] applicationActivities:@[openInActivity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Accessors

- (void)setPreviewController:(QLPreviewController *)previewController
{
    if (_previewController != previewController) {
        [_previewController willMoveToParentViewController:nil];
        [_previewController.view removeFromSuperview];
        [_previewController removeFromParentViewController];
        
        _previewController = previewController;
        
        UIView *previewView = _previewController.view;
        previewView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController:_previewController];
        
        [self.containerView addSubview:previewView];
        NSDictionary *views = NSDictionaryOfVariableBindings(previewView);
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewView]|" options:0 metrics:nil views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[previewView]|" options:0 metrics:nil views:views]];
        
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
