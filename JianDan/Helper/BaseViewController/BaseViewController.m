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

@interface BaseViewController ()

@end

@implementation BaseViewController

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
    [self initLeftnavigationBar];
}

- (void)initLeftnavigationBar
{
    UIImage* image = [UIImage imageNamed:@"common_icon_back"];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, image.size.width*2, image.size.height);
    [btn addTarget:self action:@selector(BackClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:image forState:UIControlStateNormal];
  
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barButtonItem;
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
