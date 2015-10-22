//
//  SettingController.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/5.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "SettingController.h"
#import "UMSocial.h"
#import "LTAlertView.h"
#import "TMCache.h"
#import "CacheTools.h"

@interface SettingController ()
@property(weak, nonatomic) IBOutlet UIButton *buttonSina;
@property(weak, nonatomic) IBOutlet UIButton *buttonClearCache;
@property(weak, nonatomic) IBOutlet UIButton *buttonSister;
@property(weak, nonatomic) IBOutlet UIButton *buttonAbout;
@property(weak, nonatomic) IBOutlet UILabel *labelSize;

@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    //新浪微博
    WS(ws)
    [[self.buttonSina rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if ([UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina]) {//已授权
            LTAlertView *alertView = [[LTAlertView alloc] initWithTitle:@"新浪微博" contentText:@"确认取消微博授权？" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
            [alertView show];
            alertView.rightBlock = ^{
                [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina completion:^(UMSocialResponseEntity *response) {
                    [[ToastHelper sharedToastHelper] toast:response.responseCode == UMSResponseCodeSuccess ? @"取消授权成功" : @"取消授权失败"];
                }];
            };
        }
        else {//未授权
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
            snsPlatform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response) {
                [[ToastHelper sharedToastHelper] toast:response.responseCode == UMSResponseCodeSuccess ? @"授权成功" : @"授权失败"];
            });

        }
    }];


    self.labelSize.text = [self getTotalCacheSize];
    //清除缓存
    [[self.buttonClearCache rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [ws clearAllCache];
        ws.labelSize.text = [self getTotalCacheSize];
    }];
    //开启妹子图
    [[self.buttonSister rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {

    }];
    //关于煎蛋
    [[self.buttonAbout rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        LTAlertView *alertView = [[LTAlertView alloc] initWithTitle:@"关于煎蛋" contentText:@"煎蛋，地球上没有新鲜事！" leftButtonTitle:@"WEIBO" rightButtonTitle:@"GITHUB"];
        [alertView show];
        alertView.rightBlock = ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/shenhualxt/JianDanIOS"]];
        };
        alertView.leftBlock = ^{//跳转微博主页
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weibo.cn/shenhualxt"]];
        };
    }];
}

- (NSString *)getTotalCacheSize {
    float imageSize = [[SDImageCache sharedImageCache] getSize];
    float gifImageSize = [[[TMCache sharedCache] diskCache] byteCount];
    float sqlSize = [[CacheTools sharedCacheTools] getSize];
    float totalSize = (imageSize + gifImageSize + sqlSize) / 1024.0 / 1024.0;
    return [NSString stringWithFormat:@"%.2f M", totalSize];
}

- (void)clearAllCache {
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[TMCache sharedCache] removeAllObjects];
    [[CacheTools sharedCacheTools] deleteDatabse];
}

@end
