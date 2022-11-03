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

//UIImage* decodeAVIF(NSData * data){
//    NSMutableArray<UIImage *> *AnimatedImages = @[].mutableCopy;
//    NSTimeInterval duration = 0;
//
//    unsigned char * pStreamBuf = (unsigned char *)[data bytes];
//    NSUInteger length = data.length;
//    AVIFFeature features = {0};
//    int stats = ParseHeader(pStreamBuf,length, &features);
//    if(stats != 0)
//    {
//        return nil;
//    }
//
//    int64_t pDec = (int64_t)CreateDecoder(pStreamBuf,length);
//
//    if (features.frameCount){
//        for (int frameidx = 0; frameidx < features.frameCount; frameidx++)
//        {
//            AVIFOutFrame avifOutFrame;
//            avifOutFrame.pOutBuf =(int32_t *)malloc(features.height*features.width * 4);
//            int result = DecodeImage(pDec, frameidx, &avifOutFrame);
//            if (result == 0) {
//                UIImage * image = [UIImage convertBitmapRGBA8ToUIImage:(unsigned char *)avifOutFrame.pOutBuf withWidth:features.width withHeight:features.height];
//                [AnimatedImages addObject:image];
//                duration = avifOutFrame.delayTime;
//            }
//            free(avifOutFrame.pOutBuf);
//        }
//    }
//
//    UIImage * image;
//    if (AnimatedImages.count > 1) {
//        image = [UIImage animatedImageWithImages: [AnimatedImages copy] duration:(duration/10)];
//    }else{
//        image = AnimatedImages.firstObject;
//    }
//    CloseDecoder(pDec);
//    return image;
//}


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



UIImage* decodeAVIF(NSData * data)
{
    NSMutableArray * images = [NSMutableArray new];
    avifImage* image = avifImageCreateEmpty();  // 创建AVIF的image实例,用以存储进入解码器前的YUV图像数据
    if (!image) {
    }
    avifRGBImage rgb;

    unsigned char *src_data = (unsigned char *)[data bytes];
    int src_size = (int)data.length;
    avifDecoder * avif_decoder = avifDecoderCreate();

    avifResult result = avifDecoderSetIOMemory(avif_decoder, (const uint8_t*)src_data, src_size);   // 根据图像数据初始化解码器(识别是否是动图\是否使用alpha通道)
    if (result != AVIF_RESULT_OK) {
        return nil;
    }
    result = avifDecoderParse(avif_decoder);
    if (result != AVIF_RESULT_OK) {
        return nil;
    }

    int width = avif_decoder->image->width;     // AVIF解码器探测到的待解码数据信息
    int height = avif_decoder->image->height;
    bool has_alpha = avif_decoder->alphaPresent;
    int total_frames = avif_decoder->imageCount;

    avifRGBImageSetDefaults(&rgb, avif_decoder->image); // 根据解码器设置RGB输入原图像格式
    if (has_alpha!=true) {
        rgb.format = AVIF_RGB_FORMAT_RGB;   // 不带alpha通道的, 即RGB三通道图像数据
        rgb.rowBytes = avif_decoder->image->width*3;
    }else {
        rgb.format = AVIF_RGB_FORMAT_RGBA;  // 带alpha通道的,
    }
    rgb.chromaUpsampling = AVIF_CHROMA_UPSAMPLING_FASTEST;
    rgb.depth = 8;  // 目前都采用8位输出
    avifRGBImageAllocatePixels(&rgb);   //初始化RGB对象内存
    
    uint64_t duration = 0;
    for (int idx=0;idx<total_frames;idx++) {
        avifImageTiming outtiming = {0};    // 动图delay延时数据结构体
        result = avifDecoderNthImageTiming(avif_decoder, idx, &outtiming);
        uint64_t timescale = outtiming.timescale;    // 动图delay的拍率(一秒x拍)
        duration += outtiming.durationInTimescales;  //  delay拍数
        if (result != AVIF_RESULT_OK || timescale <= 0 || duration <= 0) {
            break;
        }
        result = avifDecoderNextImage(avif_decoder);    //  调用AVIF解码
        if (result != AVIF_RESULT_OK) {
            break;
        }
        avifImageCopy(image, avif_decoder->image, AVIF_PLANES_ALL); //  取出解码器中的图像数据到image对象中,当前仍为YUV数据
        if (avifImageYUVToRGB(image, &rgb) != result) { // YUV转RGB
            break;
        }
        UIImage *img = convertAvifRGBImageToUIImage(rgb);
        [images addObject:img];
    }
    // 释放AVIF资源
    avifRGBImageFreePixels(&rgb);
    avifImageDestroy(image);
    // 释放IM相关资源
    avifDecoderDestroy(avif_decoder);
    
    UIImage * resultImage;
    if (images.count > 1) {
        resultImage = [UIImage animatedImageWithImages: [images copy] duration:(duration/1000.f)];
    }else{
        resultImage = images.firstObject;
    }
    
    return resultImage;
}

UIImage * convertAvifRGBImageToUIImage(avifRGBImage avifRGBImage)
{
    int width = avifRGBImage.width;
    int height = avifRGBImage.height;
    BOOL hasAlpha = avifRGBImage.format==0||avifRGBImage.format==3 ? false : true;
    BOOL usesU16 = avifRGBImage.depth > 8;
    size_t bitsPerComponent = usesU16 ? 16 : 8;

    size_t components = 3 + (hasAlpha ? 1 : 0);
    size_t bytesPerRow = components * bitsPerComponent;
    size_t rowBytes = avifRGBImage.rowBytes;

    if (avifRGBImage.pixels == NULL) {
        NSLog(@"");
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault ;
    if (avifRGBImage.format == AVIF_RGB_FORMAT_RGBA) {
        bitmapInfo = bitmapInfo | kCGImageAlphaLast;
    }
    
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, avifRGBImage.pixels, rowBytes * height);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CFRelease(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       bitsPerComponent,
                                       bytesPerRow,
                                       rowBytes,
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    UIImage *image = nil;
    if (nil != cgImage) {
        image = [UIImage imageWithCGImage:cgImage];
    }
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    return image;
}


@end
