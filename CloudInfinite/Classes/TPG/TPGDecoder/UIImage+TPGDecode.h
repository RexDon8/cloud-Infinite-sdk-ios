//
//  UIImage+TPGDecode.h
//  CloudInfinite
//
//  Created by garenwang on 2020/7/15.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TPGDecode)


+(UIImage*)TPGImageWithContentsOfData:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
