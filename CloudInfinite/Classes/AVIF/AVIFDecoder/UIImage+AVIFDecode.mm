//
//  UIImage+AVIFDecode.m
//  CloudInfinite
//
//  Created by garenwang on 2020/7/15.
//  Copyright © 2020 garenwang. All rights reserved.
//

#include <mach/mach_time.h>
#import "UIImage+AVIFDecode.h"
#import "include/avif.h"
#include <sys/stat.h>
#import <UIKit/UIKit.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

@implementation UIImage (AVIFDecode)

#define NAL_TYPE_EXIF_INFO    0x1000

UIImage* decodeAVIF(NSData * data){
    NSMutableArray<UIImage *> *AnimatedImages = @[].mutableCopy;
    NSTimeInterval duration = 0;

    unsigned char * pStreamBuf = (unsigned char *)[data bytes];
    NSUInteger length = data.length;
    AVIFFeature features = {0};
    int stats = ParseHeader(pStreamBuf,length, &features);
    if(stats != 0)
    {
        return nil;
    }

    int64_t pDec = (int64_t)CreateDecoder(pStreamBuf,length);

    if (features.frameCount){
        for (int frameidx = 0; frameidx < features.frameCount; frameidx++)
        {
            AVIFOutFrame avifOutFrame;
            avifOutFrame.pOutBuf =(int32_t *)malloc(features.height*features.width * 4);
            int result = DecodeImage(pDec, frameidx, &avifOutFrame);
            if (result == 0) {
                UIImage * image = [UIImage convertBitmapRGBA8ToUIImage:(unsigned char *)avifOutFrame.pOutBuf withWidth:features.width withHeight:features.height];
                [AnimatedImages addObject:image];
                duration = avifOutFrame.delayTime;
            }
            free(avifOutFrame.pOutBuf);
        }
    }

    UIImage * image;
    if (AnimatedImages.count > 1) {
        image = [UIImage animatedImageWithImages: [AnimatedImages copy] duration:(duration/10)];
    }else{
        image = AnimatedImages.firstObject;
    }
    CloseDecoder(pDec);
    return image;
}


+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
                                withWidth:(int) width
                               withHeight:(int) height {
    
    
    size_t bytesPerRow = 4 * width;
    size_t componentsPerPix = 4;
    size_t bitsPerPixel         = 8;
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, buffer, width * height * componentsPerPix);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       bitsPerPixel,
                                       bitsPerPixel * componentsPerPix,
                                       bytesPerRow,
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = nil;
    if (nil != cgImage) {
        image = [UIImage imageWithCGImage:cgImage];
    }else {
        return nil;
    }
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}

+(UIImage*)AVIFImageWithContentsOfData:(NSData*)data{
    return decodeAVIF(data);
}

@end
