//
//  FreshNewsDetailController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/7.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsDetailController.h"
#import "FreshNews.h"
#import "DMLazyScrollView.h"
#import "FreshNewsDetailViewModel.h"
#import "FreshNewsDetail.h"
#import "ShareToSinaController.h"
#import "ToastHelper.h"
#import "CommentController.h"
#import "LTAlertView.h"
#import "UMSocial.h"
#import <Social/Social.h>
#import "LTProgressWebView.h"

#define ARC4RANDOM_MAX    0x100000000


@interface FreshNewsDetailController () <UIWebViewDelegate, DMLazyScrollViewDelegate>

@property(nonatomic, strong) NSMutableArray *viewControllerArray;

@property(nonatomic, strong) DMLazyScrollView *lazyScrollView;

@property(nonatomic, copy) NSArray *freshNewsArray;

@property(nonatomic, assign) NSInteger index;

@end

@implementation FreshNewsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMenuButton];

    [self initLazyScrollView];

    [self bindingViewModel];
}

- (void)initMenuButton {
    self.freshNewsArray = [(RACTuple *) self.sendObject first];
    self.index = [[(RACTuple *) self.sendObject second] integerValue];
    UIBarButtonItem *itemShare = [self createButtonItem:@"ic_action_share"];
    UIBarButtonItem *itemChat = [self createButtonItem:@"ic_action_chat"];
    FreshNews *freshNews = self.freshNewsArray[self.index];
    [[(UIButton *) itemShare.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSMutableString *shareText = [NSMutableString stringWithFormat:@"【%@】", freshNews.title];
        [shareText appendFormat:@"%@ (来自 @煎蛋网)", freshNews.url];
        [self pushViewController:[ShareToSinaController class] object:shareText];
    }];
    [[(UIButton *) itemChat.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self pushViewController:[CommentController class] object:@(freshNews.id)];

    }];
    self.navigationItem.rightBarButtonItems = @[itemChat, itemShare];
}

- (void)initLazyScrollView {
    //加载网页数据
    self.viewControllerArray = [NSMutableArray arrayWithCapacity:self.freshNewsArray.count];
    for (NSUInteger k = 0; k < self.freshNewsArray.count; ++k) {
        [_viewControllerArray addObject:[NSNull null]];
    }
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.lazyScrollView = [[DMLazyScrollView alloc] initWithFrame:rect];
    [self.view addSubview:self.lazyScrollView];
    [self.lazyScrollView setEnableCircularScroll:YES];
    [self.lazyScrollView setAutoPlay:NO];
    self.lazyScrollView.pagingEnabled = YES;
    self.lazyScrollView.alwaysBounceHorizontal = NO;
    self.lazyScrollView.controlDelegate = self;
    self.lazyScrollView.directionalLockEnabled = YES;
    WS(ws)
    self.lazyScrollView.dataSource = ^(NSUInteger index) {
        return [ws controllerAtIndex:index];
    };
    self.lazyScrollView.numberOfPages = self.freshNewsArray.count;
    [self.lazyScrollView moveByPages:self.index animated:NO];
}

- (void)bindingViewModel {
    self.title = @"新鲜事";
    FreshNewsDetailViewModel *viewModel = [FreshNewsDetailViewModel new];
    //加载网页
    @weakify(self)
    [[viewModel.soureCommand.executionSignals switchToLatest] subscribeNext:^(NSString *html) {
        @strongify(self)
        //引用css文件的相对路径
        NSString * path = [[NSBundle mainBundle] bundlePath];
        NSURL * baseURL = [NSURL fileURLWithPath:path];
        UIWebView *webView = (UIWebView *) [self.lazyScrollView.visibleViewController.view.subviews objectAtIndex:0];
        webView.tag = 3;
        [webView loadHTMLString:html baseURL:baseURL];
    }];

    [viewModel.soureCommand.errors subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[NSErrorHelper handleErrorMessage:x]];
    }];

    [viewModel.soureCommand.executing subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] setSimleProgressVisiable:[x boolValue]];
    }];

    //开始获取详情信息
    [RACObserve(self, index) subscribeNext:^(id x) {
        UIWebView *webView = (UIWebView *) [self.lazyScrollView.visibleViewController.view.subviews objectAtIndex:0];
        if (webView.tag != 3) {//如果加载过，就不用执行了
            [viewModel.soureCommand execute:self.freshNewsArray[[x integerValue]]];
        }
    }];
}

- (UIViewController *)controllerAtIndex:(NSInteger)index {
    if (index > self.freshNewsArray.count || index < 0) return nil;
    id res = [_viewControllerArray objectAtIndex:index];
    if (res == [NSNull null]) {
        UIViewController *contr = [UIViewController new];
        contr.view.frame = [UIScreen mainScreen].bounds;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:contr.view.frame];
        [contr.view addSubview:webView];
        webView.delegate = self;
        webView.scrollView.directionalLockEnabled = YES;
        [_viewControllerArray replaceObjectAtIndex:index withObject:contr];
        return contr;
    }
    return res;
}

#pragma mark -webView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)lazyScrollViewDidEndDecelerating:(DMLazyScrollView *)pagingView atPageIndex:(NSInteger)pageIndex {
    if (_index != pageIndex) {
        self.index = pageIndex;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //清除数组中的Controller
    for (NSUInteger k = 0; k < self.freshNewsArray.count; ++k) {
        if (k == self.index) return;//除了当前页
        [_viewControllerArray replaceObjectAtIndex:k withObject:[NSNull null]];
    }
}
@end
