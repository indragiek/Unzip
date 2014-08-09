//
//  UZExtensionViewController.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZExtensionViewController.h"

@implementation UZExtensionViewController
@synthesize uz_extensionContext = _uz_extensionContext;

- (instancetype)initWithExtensionContext:(NSExtensionContext *)extensionContext
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _uz_extensionContext = extensionContext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.uz_extensionContext != nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
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

- (void)done
{
    [self.uz_extensionContext completeRequestReturningItems:self.uz_extensionContext.inputItems completionHandler:nil];
}

@end
