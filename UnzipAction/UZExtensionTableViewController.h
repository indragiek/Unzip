//
//  UZExtensionTableViewController.h
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UZExtensionTableViewController : UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style extensionContext:(NSExtensionContext *)extensionContext;

@property (nonatomic, strong, readonly) NSExtensionContext *uz_extensionContext;

@end
