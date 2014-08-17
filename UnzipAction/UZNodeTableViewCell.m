//
//  UZNodeTableViewCell.m
//  Unzip
//
//  Created by Indragie on 8/6/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZNodeTableViewCell.h"

@implementation UZNodeTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self.class);
}

+ (CGFloat)rowHeight
{
    return 52.0;
}

#pragma mark - UITableViewCell

- (void)prepareForReuse
{
    self.fileNameLabel.text = nil;
    self.fileSizeLabel.text = nil;
    self.glyphImageView.image = nil;
    [super prepareForReuse];
}

@end
