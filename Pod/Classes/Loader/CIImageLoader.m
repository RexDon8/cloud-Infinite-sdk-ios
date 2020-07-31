//
//  CITPGImageLoader.m
//  CIImageLoader
//
//  Created by garenwang on 2020/7/20.
//

#import "CIImageLoader.h"
#import <QCloudCore/QCloudCore.h>
#import "CIImageRequest.h"

@implementation CIImageLoader

+ (CIImageLoader*) shareLoader{
    static CIImageLoader* loader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[CIImageLoader alloc]init];
    });
    return loader;
}

-(void)loadData:(CIImageLoadRequest*)loadRequest
   loadComplete:(nullable LoadImageComplete)complete;{
    
    if (loadRequest.url == nil) {
        NSError * error = [NSError errorWithDomain:NSURLErrorDomain code:10000 userInfo:@{NSLocalizedDescriptionKey:@"CIImageLoader：loadData 图片URL参数异常"}];
        complete(nil,error);
        return;
    }
    
    // 用 CIImageLoadRequest 示例中构建号的url和header 初始化一个 CIImageRequest；
    CIImageRequest * request = [[CIImageRequest alloc]initWithImageUrl:loadRequest.url andHeader:loadRequest.header];
    
    // 执行CIImageRequest 示例开始请求图片
    [[QCloudHTTPSessionManager shareClient] performRequest:request withFinishBlock:^(id outputObject, NSError *error) {
        NSLog(@"%@",request);
        if (error || ![outputObject isKindOfClass:[NSDictionary class]]) {
            if (complete) {
                complete(nil,error);
            }
            return;
        }
        if (outputObject[@"data"] == nil) {
            if (complete) {
                complete(nil,error);
            }
            return;
        }
        NSData * imageData = outputObject[@"data"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(imageData,error);
            }
        });
    }];
}

-(void)display:(UIImageView *)imageView
   loadRequest:(CIImageLoadRequest*)loadRequest
   placeHolder:(UIImage *)placeHolder
  loadComplete:(nullable LoadImageComplete)complete;{
    
    if (placeHolder) {
        imageView.image = placeHolder;
    }
    
    if (loadRequest.url == nil) {
        NSError * error = [NSError errorWithDomain:NSURLErrorDomain code:10000 userInfo:@{NSLocalizedDescriptionKey:@"CIImageLoader：display 图片URL参数异常"}];
        if (complete) {
            complete(nil,error);
        }
        return;
    }
    
    // 用 CIImageLoadRequest 示例中构建号的url和header 初始化一个 CIImageRequest；
    CIImageRequest * request = [[CIImageRequest alloc]initWithImageUrl:loadRequest.url andHeader:loadRequest.header];
    
    // 执行CIImageRequest 示例开始请求图片
    [[QCloudHTTPSessionManager shareClient] performRequest:request withFinishBlock:^(id outputObject, NSError *error) {
        NSLog(@"%@",request);
        if (error || ![outputObject isKindOfClass:[NSDictionary class]]) {
            if (complete) {
                complete(nil,error);
            }
            return;
        }
        if (outputObject[@"data"] == nil) {
            if (complete) {
                complete(nil,error);
            }
            return;
        }
        NSData * imageData = outputObject[@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [UIImage imageWithData:imageData];
            if (image == nil) {
                NSError * error = [NSError errorWithDomain:NSCocoaErrorDomain code:40000 userInfo:@{NSLocalizedDescriptionKey:@"图片data数据转image错误"}];
                if (complete) {
                    complete(imageData,error);
                }
                return;
            }
            // 显示请求的image，并返回imagedata以及错误信息
            imageView.image = image;
            if (complete) {
                complete(imageData,error);
            }
        });
    }];
}

@end
