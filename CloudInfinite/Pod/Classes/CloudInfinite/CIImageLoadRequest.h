//
//  CIImageLoadRequest.h
//  CIImageLoader
//
//  Created by garenwang on 2020/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIImageLoadRequest : NSObject

/// 构建完后的url
@property (nonatomic,strong)NSURL * url;

/// 构建完后的header
@property (nonatomic,strong)NSDictionary * header;

@end

NS_ASSUME_NONNULL_END
