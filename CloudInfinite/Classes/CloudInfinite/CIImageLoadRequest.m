//
//  CIImageLoadRequest.m
//  CloudInfinite
//
//  Created by garenwang on 2020/7/23.
//

#import "CIImageLoadRequest.h"

@interface CIImageLoadRequest ()

@property(nonatomic,strong)NSString * urlPart;

@property(nonatomic,strong)NSString * baseUrl;

@property(nonatomic,strong)NSString * query;

@end

@implementation CIImageLoadRequest

-(instancetype)initWithBaseURL:(NSString *)baseUrl{
    if (self  = [super init]) {
        if ([baseUrl containsString:@"?"]) {
            self.baseUrl = [[baseUrl componentsSeparatedByString:@"?"] firstObject];
            if ([[baseUrl componentsSeparatedByString:@"?"] lastObject].length > 0) {
                if ([[[baseUrl componentsSeparatedByString:@"?"] lastObject] containsString:@"="]) {
                    self.query = [[baseUrl componentsSeparatedByString:@"?"] lastObject];
                    self.urlPart = @"";
                }else{
                    self.query = @"";
                    self.urlPart = [NSString stringWithFormat:@"?%@",[[baseUrl componentsSeparatedByString:@"?"] lastObject]];
                }
             
            }else{
                self.query = @"";
                self.urlPart = @"";
            }
            
        }else{
            self.baseUrl = baseUrl;
            self.urlPart = @"";
            self.query = @"";
        }
    }
    return self;
}


-(void)addURLPart:(NSString *)partUrl{
    if (self.urlPart.length > 0) {
        self.urlPart = [self.urlPart stringByAppendingString:@"|"];
    }else{
        self.urlPart = [self.urlPart stringByAppendingString:@"?"];
    }
    self.urlPart = [self.urlPart stringByAppendingString:partUrl];
}

-(NSURL *)url{
    
    NSString * urlStr;
    if (self.urlPart.length > 0) {
        
        if ([self.urlPart containsString:@"|"]) {
            self.urlPart = [self.urlPart  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        
        if (self.query.length > 0) {
            urlStr = [NSString stringWithFormat:@"%@%@&%@",self.baseUrl,self.urlPart,self.query];
        }else{
            urlStr = [NSString stringWithFormat:@"%@%@",self.baseUrl,self.urlPart];
        }
        
    }else{
        if (self.query.length > 0) {
            urlStr = [NSString stringWithFormat:@"%@?%@",self.baseUrl,self.query];
            
        }else{
            urlStr = self.baseUrl;
        }
        
    }
    
    return [NSURL URLWithString:urlStr];
}

@end
