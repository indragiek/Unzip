//
//  UZArchiveViewController.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZArchiveViewController.h"
#import "UZNodeViewControllerSubclass.h"
#import "UZNode.h"
#import "UZUnzipCoordinator.h"
#import "UIAlertController+UZError.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <zipzap/zipzap.h>

static void GetZipURLInItems(NSArray *inputItems, void (^completionHandler)(NSURL *URL, NSError *error))
{
    BOOL zipFound = YES;
    for (NSExtensionItem *item in inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeZipArchive]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeZipArchive options:nil completionHandler:completionHandler];
                zipFound = YES;
                break;
            }
        }
        if (zipFound) break;
    }
}

@interface UZArchiveViewController ()
@property (nonatomic, strong) ZZArchive *archive;
@end

@implementation UZArchiveViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self commonInit_UZArchiveViewController];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit_UZArchiveViewController];
    }
    return self;
}

- (void)commonInit_UZArchiveViewController
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    GetZipURLInItems(self.extensionContext.inputItems, ^(NSURL *URL, NSError *error) {
        if (error == nil) {
            self.archive = [ZZArchive archiveWithContentsOfURL:URL];
        } else {
            UIAlertController *alert = [UIAlertController uz_alertControllerWithError:error];
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (IBAction)done
{
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

#pragma mark - Accessors

- (void)setArchive:(ZZArchive *)archive
{
    if (_archive != archive) {
        _archive = archive;
        
        self.rootNode = [UZNode nodeWithArchive:_archive];
        self.unzipCoordinator = [[UZUnzipCoordinator alloc] initWithArchive:_archive];
        self.navigationItem.title = _archive.URL.lastPathComponent;
    }
}

@end
