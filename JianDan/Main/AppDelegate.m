//
//  AppDelegate.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "AppDelegate.h"
#import "FreshNewsController.h"
#import "MMDrawerController.h"
#import "LeftMenuController.h"
#import "BaseNavigationController.h"
#import "NetTypeUtils.h"
#import "AFNetworkReachabilityManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self loadRootViewController];
    [window makeKeyAndVisible];
    [[NetTypeUtils sharedNetTypeUtils] startMonitoring];
    //设置图片缓存策略（最多缓存5M的图片）
    [SDImageCache sharedImageCache].maxCacheAge = 1024 * 1024 * 5;
    return YES;
}

- (void)loadRootViewController {
    BaseNavigationController *mainNavigationVC = [[BaseNavigationController alloc] initWithRootViewController:[FreshNewsController new]];
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainNavigationVC
                                                                           leftDrawerViewController:[LeftMenuController new]];
    [drawerController setMaximumLeftDrawerWidth:200];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];//全屏滑动
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    BaseNavigationController *navigationVC = [[BaseNavigationController alloc] initWithRootViewController:drawerController];
    self.window.rootViewController = navigationVC;
}


-(void)replaceContentViewController:(UIViewController *)controller{
      MMDrawerController *drawerController = self.window.rootViewController.childViewControllers[0];
      BaseNavigationController *mainNavigationVC = [[BaseNavigationController alloc] initWithRootViewController:controller];
      [drawerController setCenterViewController:mainNavigationVC];
      [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    //清除所有的内存中图片缓存，不影响正在显示的图片
    [[SDImageCache sharedImageCache] clearMemory];
    //停止正在进行的图片下载操作
    [[SDWebImageManager sharedManager] cancelAll];
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

@end
