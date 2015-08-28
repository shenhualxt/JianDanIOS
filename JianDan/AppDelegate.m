//
//  AppDelegate.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "AppDelegate.h"
#import "MainController.h"
#import "MMDrawerController.h"
#import "LeftMenuController.h"
#import "BaseNavigationController.h"
#import "MMDrawerVisualState.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window=window;
  [self loadRootViewController];
  [window makeKeyAndVisible];
  return YES;
}

- (void)loadRootViewController {
  MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:[MainController new]
                                                         leftDrawerViewController:[LeftMenuController new]];
  [drawerController setMaximumLeftDrawerWidth:270];
  [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];//全屏滑动
  [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
  BaseNavigationController *navigationVC =[[BaseNavigationController alloc] initWithRootViewController:drawerController];
  self.window.rootViewController = navigationVC;
}


@end
