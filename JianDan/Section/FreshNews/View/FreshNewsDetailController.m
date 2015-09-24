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
#import "UIWebView+RAC.h"
#import "ToastHelper.h"
#import "CommentController.h"

@interface FreshNewsDetailController()<UIWebViewRACDelegate,UIWebViewDelegate,DMLazyScrollViewDelegate>

@property(nonatomic,strong) NSMutableArray *viewControllerArray;

@property(nonatomic,strong) DMLazyScrollView *lazyScrollView;

@property(nonatomic,copy) NSArray *freshNewsArray;

@property(nonatomic,assign) NSInteger index;

@end

@implementation FreshNewsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMenuButton];
    
    [self initLazyScrollView];
    
    [self bindingViewModel];
}

-(void)initMenuButton{
    self.freshNewsArray=[(RACTuple *)self.sendObject first];
    self.index=[[(RACTuple *)self.sendObject second] integerValue];
    UIBarButtonItem* itemShare = [self createButtonItem:@"ic_action_share"];
    UIBarButtonItem* itemChat = [self createButtonItem:@"ic_action_chat"];
    [[(UIButton *)itemShare.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        FreshNews *freshNews=self.freshNewsArray[self.index];
        NSMutableString *shareText=[NSMutableString stringWithFormat:@"【%@】", freshNews.title];
        [shareText appendFormat:@"%@ (来自 @煎蛋网)", freshNews.url];
        [self pushViewController:[ShareToSinaController class] object:shareText];
    }];
    [[(UIButton *)itemChat.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        FreshNews *freshNews=self.freshNewsArray[self.index];
        [self pushViewController:[CommentController class] object:@(freshNews.id)];
    }];
    self.navigationItem.rightBarButtonItems=@[itemChat,itemShare];
}


- (void)initLazyScrollView {
    //加载网页数据
    self.viewControllerArray=[NSMutableArray arrayWithCapacity:self.freshNewsArray.count];
    for (NSUInteger k = 0; k < self.freshNewsArray.count; ++k) {
        [_viewControllerArray addObject:[NSNull null]];
    }
    
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.lazyScrollView = [[DMLazyScrollView alloc] initWithFrame:rect];
    [self.view addSubview: self.lazyScrollView];
    [self.lazyScrollView setEnableCircularScroll:NO];
    [self.lazyScrollView setAutoPlay:NO];
    self.lazyScrollView.alwaysBounceHorizontal=YES;
    self.lazyScrollView.controlDelegate=self;
    WS(ws)
    self.lazyScrollView.dataSource = ^(NSUInteger index) {
        return [ws controllerAtIndex:index];
    };
    self.lazyScrollView.numberOfPages=self.freshNewsArray.count;
    [ self.lazyScrollView moveByPages:self.index animated:NO];
}

-(void)bindingViewModel{
    self.title=@"新鲜事";
    FreshNewsDetailViewModel *viewModel=[FreshNewsDetailViewModel new];
    //加载网页
    @weakify(self)
    [[viewModel.soureCommand.executionSignals switchToLatest] subscribeNext:^(NSString *html) {
        @strongify(self)
        //引用css文件的相对路径
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        UIWebView *webView=(UIWebView *)[self.lazyScrollView.visibleViewController.view.subviews objectAtIndex:0];
        [webView loadHTMLString:html baseURL:baseURL];
    }];
    
    [viewModel.soureCommand.errors subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[AFNetWorkUtils handleErrorMessage:x]];
    }];
    
    //开始获取详情信息
    [RACObserve(self, index) subscribeNext:^(id x) {
        RACTuple *turple=[RACTuple tupleWithObjects:self.freshNewsArray,x, nil];
        [viewModel.soureCommand execute:turple];
    }];
    
}

- (UIViewController *) controllerAtIndex:(NSInteger) index {
    if (index > self.freshNewsArray.count || index < 0) return nil;
    id res = [_viewControllerArray objectAtIndex:index];
    if (res == [NSNull null]) {
        UIViewController *contr = [UIViewController new];
        UIWebView *webView=[[UIWebView alloc] initWithFrame:self.view.frame];
        [contr.view addSubview:webView];
        [_viewControllerArray replaceObjectAtIndex:index withObject:contr];
        [webView setRACDelegate:self];
        [webView.rac_isLoadingSignal subscribeNext:^(id x) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible=[x boolValue];
            [ToastHelper sharedToastHelper].simleProgressVisiable=[x boolValue];
        }];
        return contr;
    }
    return res;
}

#pragma mark -webView delegate
-(void)rac_webViewDidFinishLoad:(UIWebView *)webView{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)lazyScrollViewDidEndDecelerating:(DMLazyScrollView *)pagingView atPageIndex:(NSInteger)pageIndex{
    self.index=pageIndex;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    //清除数组中的Controller
    for (NSUInteger k = 0; k < self.freshNewsArray.count; ++k) {
        if (k==self.index) return ;//除了当前页
        [_viewControllerArray replaceObjectAtIndex:k withObject:[NSNull null]];
    }
}
@end
