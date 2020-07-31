//
//  UIImage+TPGDecode.h
//  CIImageLoader
//
//  Created by garenwang on 2020/7/15.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TPGDecode)


+ (UIImage*) onTPGDecode;

+ (UIImage*) onTPGDecode2: (char *)InputFile
           saveoutputFIle: (char *)outputFile;

+(UIImage*)TPGImageWithContentsOfFile:(NSString*)path;

+(UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
 withWidth:(int) width
withHeight:(int) height;

@end

NS_ASSUME_NONNULL_END
