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
#import "AFNetworkReachabilityManager.h"
#import "UMSocial.h"
#import "MMDrawerBarButtonItem.h"
#import "BoredPicturesController.h"

#define UmengAppkey @"55f2639e67e58ed7da000371"

@interface AppDelegate()

@property(nonatomic,strong) NSMutableArray *controllerArray;

@property(nonatomic,strong) NSMutableArray *controllerClassArray;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.controllerArray=[NSMutableArray arrayWithCapacity:5];
    self.controllerClassArray=[NSMutableArray arrayWithObjects:[FreshNewsController class],[BoredPicturesController class],[BoredPicturesController class],[BoredPicturesController class],[BoredPicturesController class], nil];
    for (int i=0; i<5; i++) {
        [self.controllerArray addObject:[NSNull null]];
    }
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self loadRootViewController];
    [window makeKeyAndVisible];
    //设置图片缓存策略（最多缓存5M的图片）
    [SDImageCache sharedImageCache].maxCacheAge = 1024 * 1024 * 5;
    [self initURLMapping];
    [[AFNetWorkUtils sharedAFNetWorkUtils] startMonitoring];
    [UMSocialData setAppKey:UmengAppkey];
    //打开调试log的开关
//    [UMSocialData openLog:YES];
    return YES;
}

-(void)initURLMapping{
    Class class=objc_getClass([@"PushCommentController" cStringUsingEncoding:NSUTF8StringEncoding]);
    [[HHRouter shared] map:@"/FreshNews/:html/" toControllerClass:class];
}

- (void)loadRootViewController {
    [self.controllerArray replaceObjectAtIndex:0 withObject:[FreshNewsController new]];
    BaseNavigationController *mainNavigationVC = [[BaseNavigationController alloc] initWithRootViewController:self.controllerArray[0]];
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainNavigationVC
                                                                           leftDrawerViewController:[LeftMenuController new]];
    [drawerController setMaximumLeftDrawerWidth:200];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];//全屏滑动
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    BaseNavigationController *navigationVC = [[BaseNavigationController alloc] initWithRootViewController:drawerController];
    drawerController.navigationItem.rightBarButtonItem=[self createBarItemWithImage:@"ic_action_refresh"];
    MMDrawerBarButtonItem *leftItem=[self createBarItemWithImage:@"ic_drawer"];
    drawerController.navigationItem.leftBarButtonItem=leftItem;
    [[(UIButton *)leftItem.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
    
    self.window.rootViewController = navigationVC;
}

-(void)replaceContentViewController:(NSInteger)index{
    if (self.controllerArray[index]==[NSNull null]) {
        Class class=self.controllerClassArray[index];
        [self.controllerArray replaceObjectAtIndex:index withObject:[class new]];
    }
    MMDrawerController *drawerController = self.window.rootViewController.childViewControllers[0];
    BaseNavigationController *mainNavigationVC = [[BaseNavigationController alloc] initWithRootViewController:self.controllerArray[index]];
    [drawerController setCenterViewController:mainNavigationVC];
    [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(MMDrawerBarButtonItem *)createBarItemWithImage:(NSString *)imageName{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageRight = [UIImage imageNamed:imageName];
    rightButton.frame = CGRectMake(0, 0, 30, imageRight.size.height);
    [rightButton setImage:imageRight forState:UIControlStateNormal];
    rightButton.backgroundColor = [UIColor clearColor];
    return [[MMDrawerBarButtonItem alloc] initWithCustomView:rightButton];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    //清除所有的内存中图片缓存，不影响正在显示的图片
    [[SDImageCache sharedImageCache] clearMemory];
    //停止正在进行的图片下载操作
    [[SDWebImageManager sharedManager] cancelAll];
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    
    //干掉没有正在显示的controller
    MMDrawerController *drawerController = self.window.rootViewController.childViewControllers[0];
    UIViewController *centerController=[(UINavigationController *)drawerController.centerViewController viewControllers][0];
    for (int i=0;i<self.controllerArray.count;i++) {
        if (![self.controllerArray[i] isKindOfClass:[centerController class]]) {
            [self.controllerArray replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }
}

@end
