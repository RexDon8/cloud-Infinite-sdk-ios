//
//  UIImage+TPGDecode.m
//  CloudInfinite
//
//  Created by garenwang on 2020/7/15.
//  Copyright © 2020 garenwang. All rights reserved.
//

#include <mach/mach_time.h>
#import "UIImage+TPGDecode.h"
#include "TPGDecoder.h"
#include <sys/stat.h>
#import <UIKit/UIKit.h>
#include "imageUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
double total = 0;
double count = 0;

@implementation UIImage (TPGDecode)

#define NAL_TYPE_EXIF_INFO    0x1000
//#ifndef TARGET_IPHONE_SIMULATOR

UIImage* decodeTPG2JPG(NSData * data)
{
    
    unsigned char * pStreamBuf = (unsigned char *)[data bytes];
    int length = data.length;
    TPGFeatures features = {0};
    TPGStatusCode stats = TPGParseHeader(pStreamBuf, length, &features);
    if(stats != TPG_STATUS_OK)
    {
        return nullptr;
    }
    
    void* pDec = TPGDecCreate(pStreamBuf,length);
    
    const unsigned char* pInfo = NULL;
    int nlen = 0;
    stats = TPGGetAdditionalInfo(pDec,  pStreamBuf, length, NAL_TYPE_EXIF_INFO, &pInfo, &nlen);
    
    int width = features.width;
    int height = features.height;
    
    enRawDataFormat imgFormat = FORMAT_RGB;
    int bufsize = width*height*3;
    unsigned char* pOutData = (unsigned char*)malloc(bufsize);
    
    TPGOutFrame outFrame = {0};
    outFrame.dstWidth = width;
    outFrame.dstHeight = height;
    outFrame.pOutBuf = pOutData;
    outFrame.bufsize = bufsize;
    outFrame.fmt = FORMAT_RGB;
    
    mach_timebase_info_data_t info;
    volatile uint64_t starttime_c,sumtime_c=0;
    if (mach_timebase_info(&info) != KERN_SUCCESS)
    {
        printf("time unsuccess!\n");
    }
    
    starttime_c = mach_absolute_time();
    
    TPGDecodeImage(pDec, pStreamBuf, length, 0, &outFrame);
    
    sumtime_c += mach_absolute_time() - starttime_c;
    printf(" time: %lf ms\n", (double)(sumtime_c*info.numer / info.denom)/NSEC_PER_MSEC);
    total += (double)(sumtime_c*info.numer / info.denom)/NSEC_PER_MSEC;
    count ++;
    printf("\navg%lf",total/count);
    
    BitmapData bm = {0};
    bm.data = pOutData;
    bm.width = width;
    bm.height = height;
    bm.bytePerPix = 3;
    bm.componentsPerPix = 3;
    bm.bytePerRow = width*3;
    bm.PixFormat = JPEGCS_RGB;
    
    unsigned char* pOutDataRGBA = (unsigned char*)malloc(width*height*4);
    
    
    int i = 0;
    int j = 0;
    
    for(; i<width*height*4; i=i+4, j=j+3)
    {
        pOutDataRGBA[i] = pOutData[j];
        pOutDataRGBA[i+1] = pOutData[j+1];
        pOutDataRGBA[i+2] = pOutData[j+2];
        pOutDataRGBA[i+3] = 255;
    }
    
    UIImage* result = [UIImage imageFromRGBABytes:pOutDataRGBA imageSize:CGSizeMake(width, height)];
    TPGDecDestroy(pDec);
    pDec = NULL;
    free(pOutDataRGBA);
    pOutDataRGBA = NULL;
    
    free(pOutData);
    pOutData = NULL;
    
    return result;
}

UIImage* decodeTPG2PNG(NSData * data)
{
    unsigned char * pStreamBuf = (unsigned char *)[data bytes];
    int length = data.length;
    TPGFeatures features = {0};
    TPGStatusCode stats = TPGParseHeader(pStreamBuf, length, &features);
    if(stats != TPG_STATUS_OK)
    {
        return nullptr;
    }
    
    void* pDec = TPGDecCreate(pStreamBuf,length);
    
    
    int width = features.width;
    int height = features.height;
    
    enRawDataFormat imgFormat = FORMAT_RGBA;
    int bufsize = width*height*4;
    unsigned char* pOutData = (unsigned char*)malloc(bufsize);
    
    
    TPGOutFrame outFrame = {0};
    outFrame.dstWidth = width;
    outFrame.dstHeight = height;
    outFrame.pOutBuf = pOutData;
    outFrame.bufsize = bufsize;
    outFrame.fmt = imgFormat;
    
    mach_timebase_info_data_t info;
    volatile uint64_t starttime_c,sumtime_c=0;
    if (mach_timebase_info(&info) != KERN_SUCCESS)
    {
        printf("time unsuccess!\n");
    }
    
    starttime_c = mach_absolute_time();
    
    TPGDecodeImage(pDec, pStreamBuf, length, 0, &outFrame);
    
    sumtime_c = mach_absolute_time() - starttime_c;
    printf("time: %lf ms\n",(double)(sumtime_c*info.numer / info.denom)/NSEC_PER_MSEC);
    total += (double)(sumtime_c*info.numer / info.denom)/NSEC_PER_MSEC;
    count ++;
    printf("\navg%lf",total/count);
    
    pic_data outData;
    outData.width = width;
    outData.height = height;
    outData.rgba = pOutData;
    outData.flag = 1;
    outData.bit_depth = 8;
    
    
    UIImage* result = [UIImage imageFromRGBABytes:pOutData imageSize:CGSizeMake(width, height)];
    
    TPGDecDestroy(pDec);
    pDec = NULL;
    
    free(pOutData);
    pOutData = NULL;
    
    return result;
    
}


UIImage* decodeTPGGIF(NSData * data)
{
    unsigned char* pOutBuf, *pOutBuf32 = NULL;
    int nOutWidth;
    int nOutHeight;
    int nPixelSize;
    
    //decode TPG
    UIImage* result = nil;
    
    unsigned char * pStreamBuf = (unsigned char *)[data bytes];
    int stream_len = data.length;
    
    enRawDataFormat fmt = enRawDataFormat::FORMAT_RGB;
    nPixelSize = 3;
    
    TPGFeatures features = {0};
    TPGStatusCode stats = TPGParseHeader(pStreamBuf, stream_len, &features);
    
    if (TPG_STATUS_OK != stats)
    {
        printf("parse TPG header info error!\n");
        exit(1);
    }
    
    if(features.image_mode == emMode_AnimationWithAlpha)
    {
        fmt = enRawDataFormat::FORMAT_RGBA;
        nPixelSize = 4;
    }
    
    
    void *TPGDec = TPGDecCreate(pStreamBuf, stream_len);
    
    nOutWidth = features.width;
    nOutHeight = features.height;
    pOutBuf = new unsigned char[(nOutWidth + 1) * (nOutHeight + 1) * nPixelSize];
    
    if(features.image_mode == emMode_Animation)
    {
        pOutBuf32 = new unsigned char[(nOutWidth + 1) * (nOutHeight + 1) * 4];
    }
    
    TPGOutFrame outFrame = {0};
    outFrame.dstWidth = nOutWidth;
    outFrame.dstHeight = nOutHeight;
    outFrame.pOutBuf = pOutBuf;
    outFrame.bufsize = (nOutWidth + 1) * (nOutHeight + 1) * nPixelSize;
    outFrame.fmt = fmt;
    
    mach_timebase_info_data_t info;
    volatile uint64_t starttime_c,sumtime_c=0;
    if (mach_timebase_info(&info) != KERN_SUCCESS)
    {
        printf("time unsuccess!\n");
    }
    
    NSMutableArray<UIImage *> *AnimatedImages = @[].mutableCopy;
    NSTimeInterval duration = 0;
    
    if (features.image_mode == emMode_Animation || features.image_mode == emMode_AnimationWithAlpha)
    {
        
        int i = 0;
        for (i = 0; i < features.frame_count; i++)
        {
            //starttime_c = mach_absolute_time();
            stats = TPGDecodeImage(TPGDec, pStreamBuf, stream_len, i, &outFrame);
            int time = -1;
            stats = TPGGetDelayTime(TPGDec, pStreamBuf, stream_len, i, &time);
            printf("time = %d\n", time);
            if (TPG_STATUS_OK != stats)
            {
                break;
            }
            
            UIImage* oneFrame = nil;
            
            if(features.image_mode == emMode_Animation)
            {
                int i = 0;
                int j = 0;
                
                for(; i<nOutWidth*nOutHeight*4; i=i+4, j=j+3)
                {
                    pOutBuf32[i] = pOutBuf[j];
                    pOutBuf32[i+1] = pOutBuf[j+1];
                    pOutBuf32[i+2] = pOutBuf[j+2];
                    pOutBuf32[i+3] = 255;
                }
                oneFrame = [UIImage imageFromRGBABytes:pOutBuf32 imageSize:CGSizeMake(nOutWidth, nOutHeight)];
            }
            else{
                
                oneFrame = [UIImage imageFromRGBABytes:pOutBuf imageSize:CGSizeMake(nOutWidth, nOutHeight)];
            }
            
            if(oneFrame)
            {
                [AnimatedImages addObject:oneFrame];
                if(outFrame.delayTime >=2)
                {
                    duration += outFrame.delayTime *10;
                }
                else{
                    
                    duration +=100;
                }
            }
            
            starttime_c = mach_absolute_time();
            
            sumtime_c += mach_absolute_time() - starttime_c;
            
            
        }
        
    }
    
    if(AnimatedImages.count > 0)
    {
        result = [UIImage animatedImageWithImages: [AnimatedImages copy] duration:(duration/1000)];
    }
    
    TPGDecDestroy(TPGDec);
    TPGDec = NULL;
    delete [] pOutBuf;
    pOutBuf = NULL;
    if(pOutBuf32)
    {
        delete [] pOutBuf32;
        pOutBuf32 = NULL;
    }
    
    return result;
}


+ (UIImage*) onTPGDecodeWithData: (NSData *)data{
    
    UIImage *img;
    
    unsigned char * pStreamBuf = (unsigned char *)[data bytes];
    int stream_len = data.length;
    TPGFeatures features = {0};
    TPGStatusCode stats = TPGParseHeader(pStreamBuf, stream_len, &features);
    
    if (TPG_STATUS_OK != stats)
    {
        printf("parse TPG header info error!\n");
        return nullptr;
    }
    
    if (features.image_mode == emMode_Normal || features.image_mode == emMode_BlendAlpha)
    {
        
        img = decodeTPG2JPG(data);
    }
    else if (features.image_mode == emMode_EncodeAlpha)
    {
        img = decodeTPG2PNG(data);
    }
    else if (features.image_mode == emMode_Animation || features.image_mode == emMode_AnimationWithAlpha)
    {
        img = decodeTPGGIF(data);
    }
    else
    {
        printf("TPG file format error!\n");
        return nullptr;
    }
    
    return img;
}

+ (UIImage *)imageFromRGBABytes:(unsigned char *)imageBytes imageSize:(CGSize)imageSize {
    CGImageRef imageRef = [self imageRefFromRGBABytes:imageBytes imageSize:imageSize];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

+ (CGImageRef)imageRefFromRGBABytes:(unsigned char *)imageBytes imageSize:(CGSize)imageSize {
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(imageBytes,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 8,
                                                 imageSize.width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return imageRef;
}

+(UIImage*)TPGImageWithContentsOfData:(NSData*)data{
    UIImage* resultImage =  [UIImage onTPGDecodeWithData:data];
    return resultImage;
}

@end
