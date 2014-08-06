//
//  UZNodeViewController.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UZNode;

@interface UZNodeViewController : UITableViewController

- (instancetype)initWithRootNode:(UZNode *)rootNode;

@property (nonatomic, strong) UZNode *rootNode;

@end
