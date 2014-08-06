//
//  UZPreviewViewController.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZPreviewViewController.h"
#import "UZNode.h"

@interface UZPreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, strong, readonly) UZNode *node;
@end

@implementation UZPreviewViewController

#pragma mark - Lifecycle

- (instancetype)initWithNode:(UZNode *)node password:(NSString *)password
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _node = node;
        _password = [password copy];
    }
    return self;
}

@end
