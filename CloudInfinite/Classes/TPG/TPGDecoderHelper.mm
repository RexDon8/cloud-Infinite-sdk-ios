//
//  TPGDecoderHelper.m
//  CloudInfinite
//
//  Created by garenwang on 2020/7/24.
//

#import "TPGDecoderHelper.h"
#import <UIImage+TPGDecode.h>

@implementation TPGDecoderHelper

+ (UIImage *)imageDataDecode:(NSData *)imageData error:(NSError * __autoreleasing*)error{
    __block UIImage *image;
    if (imageData == nil) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:40000 userInfo:@{NSLocalizedDescriptionKey:@"TPGDecoderHelper:imageDataDecode 图片二进制数据异常"}];
        return nil;
    }
    
    if ([self isTPGImage:imageData]) {
    
        dispatch_semaphore_t semap = dispatch_semaphore_create(0);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            image = [UIImage TPGImageWithContentsOfData:imageData];
            dispatch_semaphore_signal(semap);
        });
        
        dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
        
        if (image == nil) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:40001 userInfo:@{NSLocalizedDescriptionKey:@"TPGDecoderHelper:imageDataDecode TPG图片解码失败"}];
            return nil;
        }
    }else{
        image = [UIImage imageWithData:imageData];
        if (image == nil) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:40002 userInfo:@{NSLocalizedDescriptionKey:@"TPGDecoderHelper:imageDataDecode 非tpg二进制数据转图片失败"}];
            return nil;
        }
    }
    
    return image;
}

+ (BOOL)isTPGImage:(NSData *)data{
    
    char char1 = 0 ;char char2 =0 ;char char3 = 0;
    
    [data getBytes:&char1 range:NSMakeRange(0, 1)];
    
    [data getBytes:&char2 range:NSMakeRange(1, 1)];
    
    [data getBytes:&char3 range:NSMakeRange(2, 1)];
    
    NSString *numStr = [NSString stringWithFormat:@"%c%c%c",char1,char2,char3];
    if ([numStr isEqualToString:@"TPG"]) {
        return YES;
    }
    return NO;
}

@end
