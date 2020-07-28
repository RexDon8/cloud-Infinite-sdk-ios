//
//  UIImage+TPGDecode.m
//  CIImageLoader
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

UIImage* decodeTPG2JPG(char * InputFile, char* OutputFile)
{
    FILE* fp = NULL;
    if ((fp = fopen(InputFile, "rb")) == NULL)
    {
//        printf("can't open input file :\n");
        return nullptr;
    }
    fseek(fp, 0, SEEK_END);
    int length = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    unsigned char* pStreamBuf = (unsigned char*)malloc(length);
    fread(pStreamBuf, length, 1, fp);
    fclose(fp);

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

    //encodeBitmapToFile(&bm, out_path, 80, 0);
//    encodeBitmapToFileWithExif(&bm, OutputFile, 80, 0, pInfo, nlen);



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

    UIImage* result = [UIImage convertBitmapRGBA8ToUIImage:pOutDataRGBA withWidth:width withHeight:height];

    free(pOutDataRGBA);
    pOutDataRGBA = NULL;

    TPGDecDestroy(pDec);
    pDec = NULL;

    free(pStreamBuf);
    pStreamBuf = NULL;
    free(pOutData);
    pOutData = NULL;
    return result;
}

UIImage* decodeTPG2PNG(char * InputFile, char* OutputFile)
{
    FILE* fp = NULL;
    if ((fp = fopen(InputFile, "rb")) == NULL)
    {
//        printf("can't open input file :\n");
        return nullptr;
    }
    fseek(fp, 0, SEEK_END);
    int length = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    unsigned char* pStreamBuf = (unsigned char*)malloc(length);
    fread(pStreamBuf, length, 1, fp);
    fclose(fp);

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

    UIImage* result = [UIImage convertBitmapRGBA8ToUIImage:pOutData withWidth:width withHeight:height];
  
    TPGDecDestroy(pDec);
    pDec = NULL;

    free(pStreamBuf);
    pStreamBuf = NULL;
    free(pOutData);
    pOutData = NULL;
    return result;

}


//UIImage* decodeTPGGIF(char *InputFile, char* OutputFile)
//{
//    unsigned char* pOutBuf, *pOutBuf32 = NULL;
//    int nOutWidth;
//    int nOutHeight;
//    int nPixelSize;
//
//    //decode TPG
//    UIImage* result = nil;
//
//    int stream_len = 0;
//    FILE* fp = fopen(InputFile, "rb");
//    struct stat fileInfo;
//    if(stat(InputFile,&fileInfo))
//    {
//        printf("can't find the %s file.\n",InputFile);
//        exit(1);
//    }
//    stream_len = fileInfo.st_size;
//    unsigned char* pStreamBuf = (unsigned char*)malloc(stream_len);
//    if(fread(pStreamBuf,1,stream_len,fp) !=stream_len)
//    {
//        printf("read the %s fail ");
//        exit(1);
//    }
//    fclose(fp);
//
//    enRawDataFormat fmt = enRawDataFormat::FORMAT_RGB;
//    nPixelSize = 3;
//
//    TPGFeatures features = {0};
//    TPGStatusCode stats = TPGParseHeader(pStreamBuf, stream_len, &features);
//
//    if (TPG_STATUS_OK != stats)
//    {
//        printf("parse TPG header info error!\n");
//        exit(1);
//    }
//
//    if(features.image_mode == emMode_AnimationWithAlpha)
//    {
//        fmt = enRawDataFormat::FORMAT_RGBA;
//        nPixelSize = 4;
//    }
//
//
//    void *TPGDec = TPGDecCreate(pStreamBuf, stream_len);
//
//    nOutWidth = features.width;
//    nOutHeight = features.height;
//    pOutBuf = new unsigned char[(nOutWidth + 1) * (nOutHeight + 1) * nPixelSize];
//
//    if(features.image_mode == emMode_Animation)
//    {
//        pOutBuf32 = new unsigned char[(nOutWidth + 1) * (nOutHeight + 1) * 4];
//    }
//
//    TPGOutFrame outFrame = {0};
//    outFrame.dstWidth = nOutWidth;
//    outFrame.dstHeight = nOutHeight;
//    outFrame.pOutBuf = pOutBuf;
//    outFrame.bufsize = (nOutWidth + 1) * (nOutHeight + 1) * nPixelSize;
//    outFrame.fmt = fmt;
//
//    mach_timebase_info_data_t info;
//    volatile uint64_t starttime_c,sumtime_c=0;
//    if (mach_timebase_info(&info) != KERN_SUCCESS)
//    {
//        printf("time unsuccess!\n");
//    }
//
//    NSMutableArray<UIImage *> *AnimatedImages = @[].mutableCopy;
//    NSTimeInterval duration = 0;
//
//    if (features.image_mode == emMode_Animation || features.image_mode == emMode_AnimationWithAlpha)
//    {
//        void* hGif = GifEncoderOpen(OutputFile, nOutWidth, nOutHeight, features.image_mode==emMode_AnimationWithAlpha, NULL,0);
//
//        //FILE *fRGB = fopen(OutputFile,"wb");
//        int i = 0;
//        for (i = 0; i < features.frame_count; i++)
//        {
//            //starttime_c = mach_absolute_time();
//            stats = TPGDecodeImage(TPGDec, pStreamBuf, stream_len, i, &outFrame);
//            int time = -1;
//            stats = TPGGetDelayTime(TPGDec, pStreamBuf, stream_len, i, &time);
//            printf("time = %d\n", time);
//            if (TPG_STATUS_OK != stats)
//            {
//                break;
//            }
//
//            UIImage* oneFrame = nil;
//
//            if(features.image_mode == emMode_Animation)
//            {
//                int i = 0;
//                int j = 0;
//
//                for(; i<nOutWidth*nOutHeight*4; i=i+4, j=j+3)
//                {
//                    pOutBuf32[i] = pOutBuf[j];
//                    pOutBuf32[i+1] = pOutBuf[j+1];
//                    pOutBuf32[i+2] = pOutBuf[j+2];
//                    pOutBuf32[i+3] = 255;
//                }
//                oneFrame = [UIImage convertBitmapRGBA8ToUIImage:pOutBuf32 withWidth:nOutWidth withHeight:nOutHeight];
//            }
//            else{
//                oneFrame = [UIImage convertBitmapRGBA8ToUIImage:pOutBuf withWidth:nOutWidth withHeight:nOutHeight];
//            }
//
//            if(oneFrame)
//            {
//                [AnimatedImages addObject:oneFrame];
//                if(outFrame.delayTime >=2)
//                {
//                    duration += outFrame.delayTime *10;
//                }
//                else{
//
//                    duration +=100;
//                }
//            }
//
//            starttime_c = mach_absolute_time();
//            if (hGif)
//            {
//                stGifFrame stFrame = {0};
//                stFrame.width = outFrame.dstWidth;
//                stFrame.height = outFrame.dstHeight;
//                stFrame.pRGB = outFrame.pOutBuf;
//                stFrame.delayTime = outFrame.delayTime;
//                GifEncoderEncodeFrame(hGif, &stFrame);
//            }
//            sumtime_c += mach_absolute_time() - starttime_c;
//
//            //fwrite(outFrame.pOutBuf, outFrame.dstWidth*outFrame.dstHeight*nPixelSize, 1, fRGB);
//        }
//
//        printf("decode time:  %lf ms\n",  (double)(sumtime_c*info.numer / info.denom)/NSEC_PER_MSEC);
//       // fclose(fRGB);
//       GifEncoderClose(hGif);
//    }
//
//    if(AnimatedImages.count > 0)
//    {
//        result = [UIImage animatedImageWithImages: [AnimatedImages copy] duration:(duration/1000)];
//    }
//
//
//    free(pStreamBuf);
//    pStreamBuf = NULL;
//    delete [] pOutBuf;
//    pOutBuf = NULL;
//    if(pOutBuf32)
//    {
//        delete [] pOutBuf32;
//        pOutBuf32 = NULL;
//    }
//
//    TPGDecDestroy(TPGDec);
//    TPGDec = NULL;
//
//    return result;
//}

+ (UIImage*) onTPGDecode
{

    UIImage *img;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *NspathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:NspathDocuments];
    
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:42];
    NSString *filename ;
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqual:@"tpg"]) {
            [files addObject: filename];
        }
    }
    
    NSEnumerator *fileenum;
    fileenum = [files objectEnumerator];
    
    while (filename = [fileenum nextObject]) {
        
        //        NSLog(@"%@", filename);
        NSString *NsInputFileNamepath = [NSString stringWithFormat:@"%@/%@",NspathDocuments,filename];
        int len = [NsInputFileNamepath length];
        char * InputFile = (char*)malloc(sizeof(char)*len+1);
        [NsInputFileNamepath getCString:InputFile maxLength:len+1 encoding:NSUTF8StringEncoding];
        
        NSString *NsOutputFileNamepath = [NSString stringWithFormat:@"%@/%@",NspathDocuments,filename];
        len = [NsOutputFileNamepath length];
        char * OutputFile =(char*)malloc(sizeof(char)*len+1+4);
        [NsOutputFileNamepath getCString:OutputFile maxLength:len+1 encoding:NSUTF8StringEncoding];
        
        //decode TPG
        char name[4];
        
        int stream_len = 0;
        FILE* fp = fopen(InputFile, "rb");
        struct stat fileInfo;
        if(stat(InputFile,&fileInfo))
        {
            printf("can't find the %s file.\n",InputFile);
            return nullptr;
        }
        stream_len = fileInfo.st_size;
        unsigned char* pStreamBuf = (unsigned char*)malloc(stream_len);
        if(fread(pStreamBuf,1,stream_len,fp) !=stream_len)
        {
            printf("read the file %s failed\n", InputFile);
            return nullptr;
        }
        fclose(fp);
        
        TPGFeatures features = {0};
        TPGStatusCode stats = TPGParseHeader(pStreamBuf, stream_len, &features);
        
        if (TPG_STATUS_OK != stats)
        {
            printf("parse TPG header info error!\n");
            return nullptr;
        }
        
        if (features.image_mode == emMode_Normal || features.image_mode == emMode_BlendAlpha)
        {
            strcat(OutputFile, ".jpg");
            img = decodeTPG2JPG(InputFile, OutputFile);
        }
        else if (features.image_mode == emMode_EncodeAlpha)
        {
            strcat(OutputFile, ".png");
            img = decodeTPG2PNG(InputFile, OutputFile);
        }
        else if (features.image_mode == emMode_Animation || features.image_mode == emMode_AnimationWithAlpha)
        {
            strcat(OutputFile, ".gif");
//            img = decodeTPGGIF(InputFile, OutputFile);
        }
        else
        {
            printf("TPG file format error!\n");
            return nullptr;
        }
      
        free(InputFile);
        InputFile = NULL;
        free(OutputFile);
        OutputFile = NULL;
        free(pStreamBuf);
        pStreamBuf = NULL;
    }
    return img;
}


+ (UIImage*) onTPGDecode2: (char *)InputFile
               saveoutputFIle: (char *)OutputFile
{
    
        UIImage *img;

        
        //decode TPG
        char name[4];
        
        int stream_len = 0;
        FILE* fp = fopen(InputFile, "rb");
        struct stat fileInfo;
        if(stat(InputFile,&fileInfo))
        {
            printf("can't find the %s file.\n",InputFile);
            return nullptr;
        }
        stream_len = fileInfo.st_size;
        unsigned char* pStreamBuf = (unsigned char*)malloc(stream_len);
        if(fread(pStreamBuf,1,stream_len,fp) !=stream_len)
        {
            printf("read the file %s failed\n", InputFile);
            return nullptr;
        }
        fclose(fp);
        
        TPGFeatures features = {0};
        TPGStatusCode stats = TPGParseHeader(pStreamBuf, stream_len, &features);
        
        if (TPG_STATUS_OK != stats)
        {
            printf("parse TPG header info error!\n");
            return nullptr;
        }
        
        if (features.image_mode == emMode_Normal || features.image_mode == emMode_BlendAlpha)
        {
            strcat(OutputFile, ".jpg");
            img = decodeTPG2JPG(InputFile, OutputFile);
        }
        else if (features.image_mode == emMode_EncodeAlpha)
        {
            strcat(OutputFile, ".png");
            img = decodeTPG2PNG(InputFile, OutputFile);
        }
        else if (features.image_mode == emMode_Animation || features.image_mode == emMode_AnimationWithAlpha)
        {
            strcat(OutputFile, ".gif");
//            img = decodeTPGGIF(InputFile, OutputFile);
        }
        else
        {
            printf("TPG file format error!\n");
            return nullptr;
        }
        
        free(InputFile);
        InputFile = NULL;
        free(OutputFile);
        OutputFile = NULL;
        free(pStreamBuf);
        pStreamBuf = NULL;
    
        return img;
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
    }
    else {
        //QLog_Event(MODULE_IMPB_RICHMEDIA, "Error!! CGImageCreate failed!!!");
    }
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}

+(UIImage*)TPGImageWithContentsOfFile:(NSString*)path{
    NSUInteger inputPathLength = path.length;
    char* inputFilePath = (char*)malloc(sizeof(char)*inputPathLength+1);
    [path getCString:inputFilePath maxLength:inputPathLength+1 encoding:NSUTF8StringEncoding];

    NSString* outputPathString = [NSTemporaryDirectory() stringByAppendingString:path.lastPathComponent];
    NSUInteger outputPathLength = outputPathString.length;
    char* outputFilePath =  (char*)malloc(sizeof(char)*outputPathLength+1);
    [outputPathString getCString:outputFilePath maxLength:outputPathLength+1 encoding:NSUTF8StringEncoding];
    
    UIImage* resultImage =  [UIImage onTPGDecode2:inputFilePath saveoutputFIle:outputFilePath];

    return resultImage;

}

@end
