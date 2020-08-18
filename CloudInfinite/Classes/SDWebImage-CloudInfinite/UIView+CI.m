//
//  UIView+CI.m
//  CloudInfinite
//
//  Created by garenwang on 2020/8/7.
//

#import "UIView+CI.h"
#import "CIDownloaderConfig.h"

#import "CIMemoryCache.h"
#import "CIWebImageDownloader.h"
#import "CIDownloaderManager.h"

@implementation UIView (CI)

-(void)sd_CI_preloadWithAveColor:(NSString *)urlStr{
    [self sd_CI_preloadWithAveColor:urlStr completed:nil];
}

-(void)sd_CI_preloadWithAveColor:(NSString *)urlStr
                 completed:(nullable void(^)(UIColor * color)) aveColorBlock{
    if ([urlStr containsString:@"?"]) {
        urlStr = [[urlStr componentsSeparatedByString:@"?"] firstObject];
    }
    
    urlStr = [urlStr stringByAppendingString:@"?imageAve"];
    NSURL * tempUrl = [NSURL URLWithString:urlStr];
    SDWebImageMutableContext *mutableContext = [NSMutableDictionary new];
    mutableContext[SDWebImageContextSetImageOperationKey] = urlStr;
    [self sd_internalSetImageWithURL:tempUrl placeholderImage:nil options:SDWebImageAvoidAutoSetImage context:mutableContext setImageBlock:nil progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (data == nil && image == nil) {
            if (aveColorBlock) {
                aveColorBlock(nil);
            }
            return;
        }
        
        if (data == nil) {
            UIColor *color = [self colorAtPixel:CGPointMake(1, 1) image:image];
            self.backgroundColor = color;
            if (aveColorBlock) {
                aveColorBlock(color);
            }
        }else{
            
            NSDictionary * colorDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error];
            if (colorDic == nil) {
                if (aveColorBlock) {
                    aveColorBlock(nil);
                }
                return;
            }
            
            UIColor * aveColor;
            
            NSString * colorStr = colorDic[@"RGB"];
            if (colorStr.length == 8) {
                int red = (int)strtoul([[colorStr substringWithRange:NSMakeRange(2, 2)] UTF8String], 0, 16);
                int green = (int)strtoul([[colorStr substringWithRange:NSMakeRange(4, 2)] UTF8String], 0, 16);
                int blue = (int)strtoul([[colorStr substringWithRange:NSMakeRange(6, 2)] UTF8String], 0, 16);
                aveColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
                self.backgroundColor = aveColor;
            }
            if (aveColorBlock) {
                aveColorBlock(aveColor);
            }
            
        }
        
    }];
}

- (UIColor *)colorAtPixel:(CGPoint)point image:(UIImage *)image{
    
    // Cancel if point is outside image coordinates
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }

    NSInteger pointX = trunc(point.x);
    
    NSInteger pointY = trunc(point.y);
    
    CGImageRef cgImage = image.CGImage;
    
    NSUInteger width = image.size.width;
    
    NSUInteger height = image.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int bytesPerPixel = 4;
    
    int bytesPerRow = bytesPerPixel * 1;
    
    NSUInteger bitsPerComponent = 8;
    
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 
                                                 1,
                                                 
                                                 1,
                                                 
                                                 bitsPerComponent,
                                                 
                                                 bytesPerRow,
                                                 
                                                 colorSpace,
                                                 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    
    
    // Draw the pixel we are interested in onto the bitmap context
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    
    CGContextRelease(context);
    
    
    
    // Convert color values [0..255] to floats [0.0..1.0]
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}


- (void)sd_CI_internalSetImageWithURL:(nullable NSURL *)url
                      placeholderImage:(nullable UIImage *)placeholder
                               options:(SDWebImageOptions)options
                        transformation:(nullable CITransformation *)transform
                               context:(nullable SDWebImageContext *)context
                         setImageBlock:(nullable SDSetImageBlock)setImageBlock
                              progress:(nullable SDImageLoaderProgressBlock)progressBlock
                             completed:(nullable SDInternalCompletionBlock)completedBlock{
    
    CloudInfinite * cloudInfinite = [CloudInfinite new];
    if (transform == nil) {
//        如果没有任何操作，则直接走sd加载图片方法；如果url本身就是tpg，则回来会自动解码；
        [self sd_internalSetImageWithURL:url placeholderImage:placeholder options:options context:context setImageBlock:setImageBlock progress:progressBlock completed:completedBlock];
        return;
    }
    
    if (transform.autoSetAveColor == YES) {
        [self sd_CI_preloadWithAveColor:url.absoluteString];
    }
    
    [cloudInfinite requestWithBaseUrl:url.absoluteString transform:transform request:^(CIImageLoadRequest * _Nonnull request) {
        if (request.header != nil) {
            
            [self sd_internalSetImageWithURL:request.url placeholderImage:placeholder options:options context:@{SDWebImageContextImageLoader:[[CIDownloaderManager sharedManager] getDownloaderWithHeader:@{@"accept":[NSString stringWithFormat:@"image/%@",request.header]}]} setImageBlock:setImageBlock progress:progressBlock completed:completedBlock];
        }else{
            [self sd_internalSetImageWithURL:request.url placeholderImage:placeholder options:options context:context setImageBlock:setImageBlock progress:progressBlock completed:completedBlock];
        }
    }];
}


- (void)sd_CI_internalSetImageWithURL:(nullable NSURL *)url
                      placeholderImage:(nullable UIImage *)placeholder
                               options:(SDWebImageOptions)options
                               context:(nullable SDWebImageContext *)context
                         setImageBlock:(nullable SDSetImageBlock)setImageBlock
                              progress:(nullable SDImageLoaderProgressBlock)progressBlock
                             completed:(nullable SDInternalCompletionBlock)completedBlock{
    CIDownloaderConfig * config = [CIDownloaderConfig sharedConfig];
    CloudInfinite * cloudInfinite = [CloudInfinite new];
    CITransformation * transform = [[CITransformation alloc]init];
    
    if (config.tpgRegularExpressions.allKeys > 0){
        
        BOOL isExit = NO;
        NSString * selectRegular;
        for (NSString * regular in config.tpgRegularExpressions.allKeys) {
            NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regular];
            if ([numberPre evaluateWithObject:url.absoluteString]) {
                isExit = YES;
                selectRegular = regular;
                break;
            }
        }
        
        if (isExit) {
            for (NSString * regular in config.excloudeRegularExpressions) {
                NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regular];
                if ([numberPre evaluateWithObject:url.absoluteString]) {
                    isExit = NO;
                    break;
                }
            }
        }
        
        if (isExit) {
            CILoadTypeEnum option = (CILoadTypeEnum)[[config.tpgRegularExpressions objectForKey:selectRegular] integerValue];
            [transform setFormatWith:CIImageTypeTPG options:option];
            [cloudInfinite requestWithBaseUrl:url.absoluteString transform:transform request:^(CIImageLoadRequest * _Nonnull request) {
                if (request.header != nil) {
                    NSMutableDictionary * mContext = [context mutableCopy];
                    [mContext setObject:[[CIDownloaderManager sharedManager] getDownloaderWithHeader:@{@"accept":[NSString stringWithFormat:@"image/%@",request.header]}] forKey:SDWebImageContextImageLoader];
                    
                    [self sd_CI_internalSetImageWithURL:request.url placeholderImage:placeholder options:options context:mContext setImageBlock:setImageBlock progress:progressBlock completed:completedBlock];
                }else{
                    [self sd_CI_internalSetImageWithURL:request.url placeholderImage:placeholder options:options context:context setImageBlock:setImageBlock progress:progressBlock completed:completedBlock];
                }
            }];
        }else{
            [self sd_CI_internalSetImageWithURL:url placeholderImage:placeholder options:options context:context setImageBlock:setImageBlock progress:progressBlock completed:completedBlock];
        }
    }

}
@end
