//
//  CloudImage.m
//  CIImageLoader
//
//  Created by garenwang on 2020/7/23.
//

#import "CloudImage.h"

@implementation CloudImage
-(void)requestWithBaseUrl:(NSString *)url transform:(CITransformation *)CITransformation request:(void (^) (CIImageLoadRequest * request)) request{
    NSURL * imageUrl = [NSURL URLWithString:url];
    CIImageLoadRequest * loadRequest = [[CIImageLoadRequest alloc]init];
    if (CITransformation.format == CIImageTypeTPG) {
        if (CITransformation.options & CILoadTypeUrlFooter) {
            if ([imageUrl.absoluteString containsString:@"?"]) {
                imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&imageMogr2/format/tpg",imageUrl.absoluteString]];
            }else{
                imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?imageMogr2/format/tpg",imageUrl.absoluteString]];
            }
            loadRequest.url = imageUrl;
        }else{
            loadRequest.header = @{@"accept":@"image/tpg"};
            loadRequest.url = imageUrl;
        }
    }else{
        loadRequest.url = imageUrl;
    }
    request(loadRequest);
}
@end
