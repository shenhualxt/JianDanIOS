//
//  BaseViewController.m
//  CarManager
//
//  Created by 刘献亭 on 15/3/21.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavigationController.h"
#import "SDImageCache.h"
#import "BaseTableViewController.h"
#import "PureLayout.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (instancetype)initWithSendObject:(id)sendObject {
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        self.sendObject = sendObject;
    }

    return self;
}

+ (instancetype)controllerWithSendObject:(id)sendObject {
    return [[self alloc] initWithSendObject:sendObject];
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame=self.view.frame;
     self.view.backgroundColor = [UIColor whiteColor];
    if (![UIApplication sharedApplication].statusBarHidden) {
    frame.size.height-=[UIApplication sharedApplication].statusBarFrame.size.height;
    }
    if (!self.navigationController.navigationBar.hidden) {
        frame.size.height-=self.navigationController.navigationBar.frame.size.height;
    }
    self.view.frame=frame;
    [self initLeftnavigationBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.navigationBarHidden) {
        self.navigationController.navigationBar.hidden=YES;
    }
    //默认的是黑色
    if (self.statusBarStyle==UIStatusBarStyleLightContent) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    if (self.navigationBarHidden) {
        self.navigationController.navigationBar.hidden=NO;
    }
    
    if (self.statusBarStyle==UIStatusBarStyleLightContent) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)initLeftnavigationBar
{
    UIImage* image = [UIImage imageNamed:@"common_icon_back"];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, image.size.width*3, image.size.height);
    [btn addTarget:self action:@selector(BackClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:image forState:UIControlStateNormal];
  
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)pushViewController:(Class)class object:(id)sendObject{
    if (![class isSubclassOfClass:[BaseViewController class]]&&![class isSubclassOfClass:[BaseTableViewController class]]) {
        return;
    }
    
    BaseViewController *vc=[class new];
    vc.sendObject=sendObject;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)presentViewController:(Class)class object:(id)sendObject{
    if (![class isSubclassOfClass:[BaseViewController class]]&&![class isSubclassOfClass:[BaseTableViewController class]]) {
        return;
    }
    BaseViewController *vc=[class new];

     BaseNavigationController *navigationController=[[BaseNavigationController alloc] initWithRootViewController:vc];
       vc.sendObject=sendObject;
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)popViewController:(Class)class object:(id)resultObject{
    if (![class isSubclassOfClass:[BaseViewController class]]&&![class isSubclassOfClass:[BaseTableViewController class]]) {
        return;
    }
    BaseViewController *vc=(BaseViewController*)[self findViewController:class];
    vc.resultObject=resultObject;
    [self.navigationController popToViewController:vc animated:YES];
}

- (UIViewController*)findViewController:(Class)aClass
{
    for (UIViewController* controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:aClass]) {
            return controller;
        }
    }
    return nil;
}


-(UIBarButtonItem *)createButtonItem:(NSString *)imageName{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageRight = [UIImage imageNamed:imageName];
    rightButton.frame = CGRectMake(0, 0, 30, imageRight.size.height);
    [rightButton setImage:imageRight forState:UIControlStateNormal];
    rightButton.backgroundColor = [UIColor clearColor];
    return [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

/**
 *  点击返回键的事件
 */
- (void)BackClick
{
    if (self.presentingViewController != nil && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)whenNetErrorHappened:(NSString *)tipText command:(RACCommand *)command{
    self.navigationController.navigationBar.hidden=NO;
    UIImageView *netErrorView=[[[NSBundle mainBundle] loadNibNamed:@"NetError" owner:nil options:nil] lastObject];
    netErrorView.image=[UIImage imageNamed:@"rightBg"];
    [self.view addSubview:netErrorView];
    [netErrorView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    UILabel *labelTip=(UILabel *)[netErrorView viewWithTag:3];
    labelTip.text=tipText;
    UIButton *buttonRetry=(UIButton *)[netErrorView viewWithTag:4];
    buttonRetry.rac_command=command;
    [[command.executionSignals switchToLatest] subscribeNext:^(id x) {
        [netErrorView removeFromSuperview];
    }];
}


/**
 *  初始化背景
 */
- (void)initBackGround
{
    //背景
    UIImage* image = [UIImage imageNamed:@"rightBg"];
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    //    self.view.layer.contents = (id)image.CGImage;
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.image = image;
    imageView.frame = self.view.frame;
    [self.view insertSubview:imageView atIndex:0];
//    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    LogBlue(@"%@---didReceiveMemoryWarning", self.title);
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    //清除所有的内存中图片缓存，不影响正在显示的图片
    [[SDImageCache sharedImageCache] clearMemory];
    //停止正在进行的图片下载操作
    [[SDWebImageManager sharedManager] cancelAll];
    
}

- (void)dealloc
{
    LogBlue(@"%@---delloc", self.title);
}


@end
