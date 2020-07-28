//
//  CITransformation.h
//  CIImageLoader
//
//  Created by garenwang on 2020/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//请求tpg图时高级选项
typedef NS_OPTIONS(NSUInteger,CIImageLoadOptions){
    

    /**
     加载类型 方式一：带 accpet 头部 accpet:image/ ***
     */
    CILoadTypeAcceptHeader = 0 << 1,
    
    /**
      加载类型 方式二：在 url 后面中拼接 imageMogr2/format/ ***
      如果需要方式二，则使用该值；不传默认为第一种方式
     */
    CILoadTypeUrlFooter = 1 << 1,
};


typedef NS_ENUM(NSUInteger,CIImageFormat) {
    CIImageTypeTPG,
    CIImageTypePNG,
    CIImageTypeJPG,
    CIImageTypeUnknown,
} ;

@interface CITransformation : NSObject

/// 图片格式
@property(nonatomic,assign)CIImageFormat format;

/// 高级选项
@property(nonatomic,assign)CIImageLoadOptions options;


/// 使用图片格式和高级选项构造一个 CITransformation实例
/// @param format 图片格式
/// @param options ImageLoadOptions
-(instancetype)initWithFormat:(CIImageFormat)format options:(CIImageLoadOptions)options;

-(instancetype)initWithCropWidth:(CGFloat)width height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
