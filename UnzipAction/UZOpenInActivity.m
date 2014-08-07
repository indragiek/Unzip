//
//  UZOpenInActivity.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZOpenInActivity.h"

@interface UZOpenInActivity () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, weak, readonly) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) NSURL *documentURL;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@end

@implementation UZOpenInActivity

- (instancetype)initWithBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if ((self = [super init])) {
        _barButtonItem = barButtonItem;
    }
    return self;
}

#pragma mark - UIActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return NSStringFromClass(self.class);
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Open In", nil);
}

- (UIImage *)activityImage
{
    return nil; // TODO: Put it an icon
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count != 1) return NO;
    return [activityItems[0] isKindOfClass:NSURL.class];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.documentURL = activityItems[0];
}

- (void)performActivity
{
    self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:self.documentURL];
    self.docInteractionController.delegate = self;
    [self.docInteractionController presentOpenInMenuFromBarButtonItem:self.barButtonItem animated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    self.docInteractionController = nil;
    [self activityDidFinish:YES];
}

@end
