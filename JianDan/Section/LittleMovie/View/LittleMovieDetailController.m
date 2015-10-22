//
//  LittleMovieDetailController.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/4.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "LittleMovieDetailController.h"
#import "PopoverView.h"
#import "ShareToSinaController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "UIWebView+RAC.h"
#import "LTProgressWebView.h"

@interface LittleMovieDetailController () <UIWebViewDelegate>

@property(weak, nonatomic) IBOutlet LTProgressWebView *webView;
@property(weak, nonatomic) IBOutlet UIButton *buttonPrevious;
@property(weak, nonatomic) IBOutlet UIButton *buttonNext;
@property(weak, nonatomic) IBOutlet UIButton *buttonRefreshOrCancel;

@property(strong, nonatomic) NJKWebViewProgress *progressProxy;

@end

@implementation LittleMovieDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    //webView 和右菜单
    [self initView];
    //绑定事件
    [self bindingViewModel];
}

- (void)initView {
    //加载网页 self.sendObject:urlString
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.sendObject]]];

    //添加右菜单
    UIBarButtonItem *item = [self createButtonItem:@"abc_ic_menu_moreoverflow_mtrl_alpha"];
    self.navigationItem.rightBarButtonItem = item;

    WS(ws)
    [[(UIButton *) item.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSArray * titles = @[@"分享", @"复制链接", @"浏览器打开"];
        [ws initPopView:titles];
    }];
}


- (void)initPopView:(NSArray *)titles {
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.size.width = SCREEN_WIDTH * 1.0 / 2.0;
    frame.origin.x = SCREEN_WIDTH - frame.size.width - 8;
    PopoverView *pop = [[PopoverView alloc] initWithBtnFrame:frame titles:titles images:nil];
    pop.selectRowAtIndex = ^(NSInteger index) {
        switch (index) {
            case 0://分享
                [self pushViewController:[ShareToSinaController class] object:self.sendObject];
                break;
            case 1://复制链接
                if (self.sendObject) {
                    [UIPasteboard generalPasteboard].string = self.sendObject;
                    [[ToastHelper sharedToastHelper] toast:copySuccess];
                }
                break;
            case 2://浏览器打开
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.sendObject]];
                break;
            default:
                break;
        }
    };
    [pop show];
}

- (void)bindingViewModel {
    WS(ws)
    //下一步
    [[self.buttonNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (ws.webView.canGoForward) {
            [ws.webView goForward];
        }
    }];
    //上一步
    [[self.buttonPrevious rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (ws.webView.canGoBack) {
            [ws.webView goBack];
        }
    }];
    //刷新或者取消加载
    [[self.buttonRefreshOrCancel rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (ws.webView.isLoading) {
            [ws.webView stopLoading];
        } else {
            [ws.webView reload];
        }
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.buttonNext.enabled = self.webView.canGoForward;
    self.buttonPrevious.enabled = self.webView.canGoBack;
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    UIImage * image = [UIImage imageNamed:@"ic_close_white_24dp"];
    [self.buttonRefreshOrCancel setImage:image forState:UIControlStateNormal];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIImage * image = [UIImage imageNamed:@"ic_action_refresh"];
    [self.buttonRefreshOrCancel setImage:image forState:UIControlStateNormal];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFinishLoad:webView];
}

@end
