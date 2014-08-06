//
//  UZPreviewViewController.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@class UZNode;

@interface UZPreviewViewController : UIViewController

- (instancetype)initWithNode:(UZNode *)node password:(NSString *)password;

@end
