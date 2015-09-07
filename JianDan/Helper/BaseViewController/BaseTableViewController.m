//
//  BaseTableViewController.m
//  CarManager
//
//  Created by 刘献亭 on 15/5/2.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];

  if (self) {
    // 解决父类UIViewController带导航条添加ScorllView坐标系下沉64像素的问题（ios7）
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
      self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.hidesBottomBarWhenPushed = YES;
  }

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self initLeftnavigationBar];

  //设置透明
  self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
//  self.tableView.backgroundView = nil;
//  self.tableView.backgroundView.alpha = 0;
//  self.tableView.backgroundColor = [UIColor clearColor];
//  self.tableView.opaque = NO;

  //处理UIViewController的可视区域的高度
  if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
    CGRect contentRect = self.view.frame;

    //减去导航条的高度
    if (!self.navigationController.navigationBarHidden) {
      contentRect.size.height -=
          self.navigationController.navigationBar.frame.size.height;
      contentRect.origin.y +=
          self.navigationController.navigationBar.frame.size.height;

      //减去状态栏的高度
      if (![UIApplication sharedApplication].statusBarHidden) {
        contentRect.size.height -=
            [UIApplication sharedApplication].statusBarFrame.size.height;
        contentRect.origin.y +=
            [UIApplication sharedApplication].statusBarFrame.size.height;
      }
    }

    //减去tabBar的高度
    if ((self.tabBarController != nil) &&
        !self.tabBarController.hidesBottomBarWhenPushed) {
      contentRect.size.height = contentRect.size.height -
                                self.tabBarController.tabBar.frame.size.height;
    }

    self.view.frame = contentRect;
  }
}

- (void)initLeftnavigationBar {
  UIImage *image = [UIImage imageNamed:@"common_icon_back"];
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
  [btn addTarget:self
                action:@selector(BackClick)
      forControlEvents:UIControlEventTouchUpInside];
  [btn setBackgroundImage:image forState:UIControlStateNormal];
  UIBarButtonItem *barButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:btn];
  self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)BackClick {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
