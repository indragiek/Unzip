//
//  UZPreviewPageViewController.h
//  Unzip
//
//  Created by Indragie on 8/8/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UZNode;
@class UZUnzipCoordinator;

@interface UZPreviewPageViewController : UIPageViewController

- (instancetype)initWithRootNode:(UZNode *)rootNode
               startingChildNode:(UZNode *)startingChildNode
                unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
                extensionContext:(NSExtensionContext *)extensionContext;

@end
