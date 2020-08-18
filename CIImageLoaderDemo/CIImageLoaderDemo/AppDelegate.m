//
//  AppDelegate.m
//  CIImageLoaderDemo
//
//  Created by garenwang on 2020/7/17.
//  Copyright © 2020 garenwang. All rights reserved.
//

#import "AppDelegate.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImage-CloudInfinite.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    方式一全局使用TPG
//    [[TPGDownloaderConfig sharedConfig] addTPGRegularExpress:@"http(s)?:.*" paramsType:CILoadTypeUrlFooter];
//    
//    // 排除主题色的请求
//    [[TPGDownloaderConfig sharedConfig] addExcloudeTPGRegularExpress:@"http(s)?:.*imageAve"];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
