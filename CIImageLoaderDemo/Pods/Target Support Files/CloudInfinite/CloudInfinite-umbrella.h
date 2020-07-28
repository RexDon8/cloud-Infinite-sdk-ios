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
#import "CITransformation.h"
#import "CloudImage.h"
#import "CIImageLoader.h"
#import "CIImageRequest.h"
#import "TPGImageDecoder.h"
#import "TPGWebImageDownloader.h"
#import "TPGDecoderHelper.h"
#import "TPGImageView.h"
#import "UIImage+TPGDecode.h"
#import "imageUtil.h"
#import "tpgDecoder.h"

FOUNDATION_EXPORT double CloudInfiniteVersionNumber;
FOUNDATION_EXPORT const unsigned char CloudInfiniteVersionString[];

