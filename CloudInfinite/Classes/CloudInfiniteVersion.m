#import "CloudInfiniteVersion.h"
NSString * const CloudInfiniteModuleVersion = @"1.3.0";
NSString * const CloudInfiniteModuleName = @"CloudInfinite";
@interface QCloudCloudInfiniteLoad : NSObject
@end

@implementation QCloudCloudInfiniteLoad
+ (void) load
{
    Class cla = NSClassFromString(@"QCloudSDKModuleManager");
    if (cla) {
        NSMutableDictionary* module = [@{
                                 @"name" : CloudInfiniteModuleName,
                                 @"version" : CloudInfiniteModuleVersion
                                 } mutableCopy];

          NSString* buglyID = @"";
          if (buglyID.length > 0) {
              module[@"crashID"] = buglyID;
          }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        id share = [cla performSelector:@selector(shareInstance)];
        [share performSelector:@selector(registerModuleByJSON:) withObject:module];
#pragma clang diagnostic pop
    }
}
@end
