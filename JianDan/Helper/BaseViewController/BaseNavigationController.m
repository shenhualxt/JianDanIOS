//
//  BaseNavigationController.m
//  CarWin
//
//  Created by 李昀 on 15/3/6.
//  Copyright (c) 2015年 李昀. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=UIColorFromRGB(0xFFFFFF);
    self.navigationBar.barStyle = UIStatusBarStyleDefault;
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];//设置当行条颜色
    int fontSize = iPhone6 ? 20 : 23;
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:fontSize], NSFontAttributeName, nil]];
}

@end
