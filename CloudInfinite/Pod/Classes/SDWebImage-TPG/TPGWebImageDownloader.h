//
//  TPGWebImageDownloader.h
//  CIImageLoader
//
//  Created by garenwang on 2020/7/24.
//

#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN


@interface TPGWebImageDownloader : SDWebImageDownloader

+ (instancetype) shareLoader;


/// 使用自定义header初始化downloader
/// @param header 自定义header
- (instancetype)initWithHeader:(NSDictionary *)header;

/// 设置请求头
/// @param headers 请求头
-(void)setHttpHeaderField:(NSDictionary *)headers;

@end

NS_ASSUME_NONNULL_END
