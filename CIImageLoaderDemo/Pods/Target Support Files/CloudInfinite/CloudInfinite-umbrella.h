#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CIImageLoadRequest.h"
#import "CIMemoryCache.h"
#import "CIResponsiveTransformation.h"
#import "CISmartFaceTransformation.h"
#import "CITransformActionProtocol.h"
#import "CITransformation.h"
#import "CloudInfinite.h"
#import "CloudInfiniteEnum.h"
#import "CloudInfiniteTools.h"
#import "CIGaussianBlur.h"
#import "CIImageChangeType.h"
#import "CIImageRotate.h"
#import "CIImageSharpen.h"
#import "CIImageStrip.h"
#import "CIImageTailor.h"
#import "CIImageZoom.h"
#import "CIQualityChange.h"
#import "CIWaterImageMark.h"
#import "CIWaterTextMark.h"
#import "CIImageLoader.h"
#import "CIImageRequest.h"
#import "CIDownloaderConfig.h"
#import "CIDownloaderManager.h"
#import "CIImageAveDecoder.h"
#import "CIWebImageDownloader.h"
#import "CIWebpImageDecoder.h"
#import "SDWebImage-CloudInfinite.h"
#import "TPGImageDecoder.h"
#import "UIButton+CI.h"
#import "UIImageView+CI.h"
#import "UIView+CI.h"
#import "TPGDecoderHelper.h"
#import "UIImageView+TPG.h"
#import "UIImage+TPGDecode.h"
#import "imageUtil.h"
#import "tpgDecoder.h"

FOUNDATION_EXPORT double CloudInfiniteVersionNumber;
FOUNDATION_EXPORT const unsigned char CloudInfiniteVersionString[];

