//
//  TPGImageDecoder.m
//  CloudInfinite
//
//  Created by garenwang on 2020/7/24.
//

#import "TPGImageDecoder.h"



/// 当请求方式为urlfooter时 直接将该解码器添加到sd，实现自动解码；
@implementation TPGImageDecoder

+ (void)load{
    
   [[SDImageCodersManager sharedManager] addCoder:[TPGImageDecoder new]];
}

- (BOOL)canDecodeFromData:(nullable NSData *)data{
    if (data == nil) {
        return NO;
    }
    Class clazz = NSClassFromString(@"TPGDecoderHelper");
    if (clazz != nil) {
        if ([clazz respondsToSelector:@selector(isTPGImage:)]) {
            return [clazz performSelector:@selector(isTPGImage:) withObject:data];
        }
    }else{
        @throw [[NSException alloc]initWithName:NSObjectNotAvailableException reason:@"如需TPG解码功能，请在podfile文件中依赖：CloudInfinite/TPG 模块" userInfo:nil];
    }
    return NO;
}

- (nullable UIImage *)decodedImageWithData:(nullable NSData *)data
                                   options:(nullable SDImageCoderOptions *)options{
    
    if (data == nil) {
        return nil;
    }
    
    Class clazz = NSClassFromString(@"TPGDecoderHelper");
    if (clazz != nil) {
        if ([clazz respondsToSelector:@selector(imageDataDecode:error:)]) {
            UIImage * image = [clazz performSelector:@selector(imageDataDecode:error:) withObject:data withObject:nil];
            return image;
        }
    }else{
         @throw [[NSException alloc]initWithName:NSObjectNotAvailableException reason:@"如需TPG解码功能，请在podfile文件中依赖：CloudInfinite/TPG 模块" userInfo:nil];
    }
    
    return nil;
}


@end
