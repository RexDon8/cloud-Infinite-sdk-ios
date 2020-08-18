//
//  UIImageView+TPG.m
//  CloudInfinite
//
//  Created by garenwang on 2020/7/10.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import "UIImageView+TPG.h"
#import "TPGDecoderHelper.h"



@implementation UIImageView(TPG)


-(void)setTpgImageWithPath:(NSURL *)fileUrl
              loadComplete:(nullable TPGImageViewLoadComplete)complete{
    self.image = [UIImage new];
    __block NSData * imageData ;
    dispatch_semaphore_t smp = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        imageData = [NSData dataWithContentsOfURL:fileUrl];
        dispatch_semaphore_signal(smp);
    });
    dispatch_semaphore_wait(smp, DISPATCH_TIME_FOREVER);
    [self setTpgImageWithData:imageData loadComplete:complete];
}

-(void)setTpgImageWithData:(NSData *)imageData
              loadComplete:(nullable TPGImageViewLoadComplete)complete{
    
    self.image = [UIImage new];
    
    __block UIImage * image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError * error;
        image = [TPGDecoderHelper imageDataDecode:imageData error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
            if (complete) {
                complete(imageData,image,error);
            }
        });
    });
    
}


@end
