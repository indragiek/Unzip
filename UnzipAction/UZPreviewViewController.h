//
//  UZPreviewViewController.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZExtensionViewController.h"

@class UZNode;
@class UZUnzipCoordinator;

@interface UZPreviewViewController : UZExtensionViewController

- (instancetype)initWithNode:(UZNode *)node
                    password:(NSString *)password
            unzipCoordinator:(UZUnzipCoordinator *)unzipCoordinator
            extensionContext:(NSExtensionContext *)extensionContext;

@end
