//
//  UZGlyphFactory.m
//  Unzip
//
//  Created by Indragie on 8/16/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZGlyphFactory.h"
#import <MobileCoreServices/MobileCoreServices.h>

static NSMutableDictionary *_tintedImages = nil;

static NSString * FileTypeForUTI(CFStringRef UTI)
{
    NSString *fileType = nil;
    if (UTTypeConformsTo(UTI, kUTTypeArchive)) {
        fileType = @"Archive";
    } else if (UTTypeConformsTo(UTI, kUTTypeAudio)) {
        fileType = @"Audio";
    } else if (UTTypeConformsTo(UTI, kUTTypeSourceCode)) {
        fileType = @"Code";
    } else if (UTTypeConformsTo(UTI, kUTTypeDirectory)) {
        fileType = @"Directory";
    } else if (UTTypeConformsTo(UTI, kUTTypeFont)) {
        fileType = @"Font";
    } else if (UTTypeConformsTo(UTI, kUTTypeImage)) {
        fileType = @"Image";
    } else if (UTTypeConformsTo(UTI, kUTTypePresentation)) {
        fileType = @"Presentation";
    } else if (UTTypeConformsTo(UTI, kUTTypeSpreadsheet)) {
        fileType = @"Spreadsheet";
    } else if (UTTypeConformsTo(UTI, kUTTypeVideo)) {
        fileType = @"Video";
    } else if (UTTypeConformsTo(UTI, kUTTypeXML) || UTTypeConformsTo(UTI, kUTTypeHTML)) {
        fileType = @"XML";
    } else {
        fileType = @"Generic";
    }
    return fileType;
}

static UIImage * MaskImageForUTI(CFStringRef UTI)
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"FileType%@", FileTypeForUTI(UTI)]];
}

static UIImage * TintedImageFromMask(UIImage *mask, UIColor *tintColor)
{
    UIGraphicsBeginImageContextWithOptions(mask.size, NO, mask.scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    const CGRect bounds = (CGRect){ .size = mask.size };
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, CGRectGetHeight(bounds));
    CGContextConcatCTM(ctx, flipVertical);
    
    CGContextClipToMask(ctx, bounds, mask.CGImage);
    [tintColor set];
    UIRectFill(bounds);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIColor * SystemDefaultTintColor()
{
    static UIColor *tintColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tintColor = [[[UIView alloc] initWithFrame:CGRectZero] tintColor];
    });
    return tintColor;
}

static UIImage * GlyphImageForUTI(CFStringRef UTI)
{
    NSCAssert([NSThread isMainThread], @"This function can only be called from the main thread.");
    
    UIImage *image = _tintedImages[(__bridge NSString *)UTI];
    if (image == nil) {
        image = TintedImageFromMask(MaskImageForUTI(UTI), SystemDefaultTintColor());
        if (_tintedImages == nil) {
            _tintedImages = [[NSMutableDictionary alloc] init];
        }
        _tintedImages[(__bridge NSString *)UTI] = image;
    }
    return image;
}

UIImage * UZDirectoryGlyphImage(UIColor *tintColor)
{
    return GlyphImageForUTI(kUTTypeDirectory);
}

UIImage * UZFileGlyphImage(NSString *fileName, UIColor *tintColor)
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileName.pathExtension, NULL);
    UIImage *image = GlyphImageForUTI(UTI);
    CFRelease(UTI);
    return image;
}
