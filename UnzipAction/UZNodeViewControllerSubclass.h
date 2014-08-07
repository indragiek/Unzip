//
//  UZNodeViewControllerSubclass.h
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#ifndef Unzip_UZNodeViewControllerSubclass_h
#define Unzip_UZNodeViewControllerSubclass_h

@interface UZNodeViewController ()
@property (nonatomic, strong, readwrite) UZNode *rootNode;
@property (nonatomic, strong, readwrite) UZUnzipCoordinator *unzipCoordinator;
@end

#endif
