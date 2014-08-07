//
//  UZNodeViewController.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZExtensionTableViewController.h"

@class UZNode;
@class UZUnzipCoordinator;

@interface UZNodeViewController : UZExtensionTableViewController

- (instancetype)initWithRootNode:(UZNode *)rootNode
                unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
                extensionContext:(NSExtensionContext *)extensionContext;

@property (nonatomic, strong, readonly) UZNode *rootNode;
@property (nonatomic, strong, readonly) UZUnzipCoordinator *unzipCoordinator;

@end
