//
//  UZExtensionTableViewController.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZExtensionTableViewController.h"

@implementation UZExtensionTableViewController
@synthesize uz_extensionContext = _uz_extensionContext;

- (instancetype)initWithStyle:(UITableViewStyle)style extensionContext:(NSExtensionContext *)extensionContext
{
    if ((self = [super initWithStyle:style])) {
        _uz_extensionContext = extensionContext;
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
