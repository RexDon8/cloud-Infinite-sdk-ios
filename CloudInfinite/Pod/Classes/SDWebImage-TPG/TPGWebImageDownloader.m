//
//  TPGWebImageDownloader.m
//  CIImageLoader
//
//  Created by garenwang on 2020/7/24.
//

#import "TPGWebImageDownloader.h"
#import "TPGImageDecoder.h"

@implementation TPGWebImageDownloader

+ (instancetype) shareLoader {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [TPGWebImageDownloader new];
    });
    
    return instance;
}

- (instancetype)initWithHeader:(NSDictionary *)header
{
    self = [super init];
    if (self) {
        [self setHttpHeaderField:header];
    }
    return self;
}

- (id<SDWebImageOperation>)requestImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    
    
    NSLog(@"%@",url);
    NSMutableDictionary * mContext = [context mutableCopy];
    
    // 将自定义解码器加到 SDWebImageContext 中，sd内部会获取到该解码器，然后进行解码操作；
    [mContext setObject:[TPGImageDecoder new] forKey:SDWebImageContextImageCoder];
    return [super requestImageWithURL:url options:options context:[mContext copy] progress:progressBlock completed:completedBlock];
}

-(void)setHttpHeaderField:(NSDictionary *)headers{
    for (NSString * key in headers.allKeys) {
        [self setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
}

@end
