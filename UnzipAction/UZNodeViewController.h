//
//  UZNodeViewController.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UZNode;
@class UZUnzipCoordinator;

@interface UZNodeViewController : UITableViewController

- (instancetype)initWithRootNode:(UZNode *)rootNode
                unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator;

@property (nonatomic, strong, readonly) UZNode *rootNode;
@property (nonatomic, strong, readonly) UZUnzipCoordinator *unzipCoordinator;

@end
