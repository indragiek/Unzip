//
//  UZGlyphFactory.m
//  Unzip
//
//  Created by Indragie on 8/16/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "UZGlyphFactory.h"
#import <MobileCoreServices/MobileCoreServices.h>

static UIImage * ImageForUTI(CFStringRef UTI)
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
    return [UIImage imageNamed:[NSString stringWithFormat:@"FileType%@", fileType]];
}

UIImage * UZDirectoryGlyphImage(UIColor *tintColor)
{
    return ImageForUTI(kUTTypeDirectory);
}

UIImage * UZFileGlyphImage(NSString *fileName, UIColor *tintColor)
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileName.pathExtension, NULL);
    UIImage *image = ImageForUTI(UTI);
    CFRelease(UTI);
    return image;
}
