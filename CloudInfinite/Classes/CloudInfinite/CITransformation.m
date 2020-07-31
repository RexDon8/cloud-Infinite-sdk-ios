//
//  CITransformation.m
//  CIImageLoader
//
//  Created by garenwang on 2020/7/23.
//

#import "CITransformation.h"

@implementation CITransformation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.options = CILoadTypeAcceptHeader;
        self.format = CIImageTypeJPG;
    }
    return self;
}

-(instancetype)initWithFormat:(CIImageFormat)format options:(CIImageLoadOptions)options{
    
    if (self = [super init]) {
        self.format = format;
        self.options = options;
    }
    return self;
}

-(instancetype)initWithCropWidth:(CGFloat)width height:(CGFloat)height{
    if (self = [super init]) {
        
    }
    return self;
}

@end
