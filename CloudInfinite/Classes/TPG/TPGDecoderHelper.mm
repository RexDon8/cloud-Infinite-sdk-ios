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
    UIImage *image;
    if (imageData == nil) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:40000 userInfo:@{NSLocalizedDescriptionKey:@"TPGDecoderHelper:imageDataDecode 图片二进制数据异常"}];
        return nil;
    }
    
    if ([self isTPGImage:imageData]) {
        NSString* tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
        tempFilePath = [tempFilePath stringByAppendingString:@".tpg"];
        [imageData writeToFile:tempFilePath atomically:YES];
        image = [UIImage TPGImageWithContentsOfFile:tempFilePath];
        if (image == nil) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:40001 userInfo:@{NSLocalizedDescriptionKey:@"TPGDecoderHelper:imageDataDecode TPG图片解码失败"}];
            return nil;
        }
        [self cleanTemporaryDirectory:tempFilePath];
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

+ (void)cleanTemporaryDirectory:(NSString *)filePath{
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:filePath] error:nil];
}
@end
