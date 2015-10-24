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
@property(weak, nonatomic) IBOutlet UIButton *buttonAbout;
@property(weak, nonatomic) IBOutlet UILabel *labelSize;
@property (weak, nonatomic) IBOutlet UISwitch *switchGIF;
@property (weak, nonatomic) IBOutlet UISwitch *switchSister;
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

    //清除缓存
    [[self getTotalCacheSize] subscribeNext:^(NSString *totalSize) {
        ws.labelSize.text=totalSize;
    }];
    self.buttonClearCache.rac_command=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[ws clearAllCache] flattenMap:^RACStream *(id value) {
            return [ws getTotalCacheSize];
        }];
    }];
    [[self.buttonClearCache.rac_command.executionSignals switchToLatest] subscribeNext:^(NSString *totalSize) {
        ws.labelSize.text =totalSize;
    }];
    [self.buttonClearCache.rac_command.executing subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] setSimleProgressVisiable:[x boolValue]];
    }];

    //开启妹子图
    RACChannelTerminal *sisterChannel=self.switchSister.rac_newOnChannel;
    RACChannelTerminal *loadSisterChannal=[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kLoadSisterKey];
    [sisterChannel subscribe:loadSisterChannal];
    [loadSisterChannal subscribe:sisterChannel];
    [sisterChannel subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[x boolValue]?@"返回到左菜单看一下，有什么变化":@"妹子图已关闭"];
    }];
    
    //wifi下自动下载GIF
    RACChannelTerminal *gifChannel=self.switchGIF.rac_newOnChannel;
    RACChannelTerminal *loadGifChannal=[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kAutoLoadGIFKey];
    [gifChannel subscribe:loadGifChannal];
    [loadGifChannal subscribe:gifChannel];
    [[self.switchGIF rac_newOnChannel] subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[x boolValue]?@"已打开自动下载":@"已关闭自动下载"];
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

- (RACSignal *)getTotalCacheSize {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger imageSize) {
            float gifImageSize = [[[TMCache sharedCache] diskCache] byteCount];
            float sqlSize = [[CacheTools sharedCacheTools] getSize];
            float totalSize = (imageSize+ gifImageSize + sqlSize) / 1024.0 / 1024.0;
            [subscriber sendNext:[NSString stringWithFormat:@"%.2fM", totalSize]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)clearAllCache {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SDImageCache sharedImageCache]  clearDiskOnCompletion:^{
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [[TMCache sharedCache] removeAllObjects];
            [[CacheTools sharedCacheTools] deleteDatabse];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

@end
