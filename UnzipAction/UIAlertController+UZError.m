//
//  UIAlertController+UZError.m
//  Unzip
//
//  Created by Indragie on 8/5/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UIAlertController+UZError.h"

@implementation UIAlertController (UZError)

+ (instancetype)uz_alertControllerWithError:(NSError *)error
{
    UIAlertController *alert = [self alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    return alert;
}

@end
