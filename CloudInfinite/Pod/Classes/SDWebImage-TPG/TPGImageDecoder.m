//
//  TPGImageDecoder.m
//  CIImageLoader
//
//  Created by garenwang on 2020/7/24.
//

#import "TPGImageDecoder.h"
#import "TPGDecoderHelper.h"
@implementation TPGImageDecoder
- (BOOL)canDecodeFromData:(nullable NSData *)data{
    if (data == nil) {
        return NO;
    }
    return [TPGDecoderHelper isTPGImage:data];
}


- (nullable UIImage *)decodedImageWithData:(nullable NSData *)data
                                   options:(nullable SDImageCoderOptions *)options{
    
    if (data == nil) {
        return nil;
    }
    
    NSError * error;
    UIImage * image = [TPGDecoderHelper imageDataDecode:data error:&error];
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
    return image;
}


@end
