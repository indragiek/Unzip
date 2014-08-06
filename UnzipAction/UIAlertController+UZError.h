//
//  UIAlertController+UZError.h
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (UZError)

+ (instancetype)uz_alertControllerWithError:(NSError *)error;

@end
