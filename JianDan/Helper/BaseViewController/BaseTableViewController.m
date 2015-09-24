//
//  BaseTableViewController.m
//  CarManager
//
//  Created by 刘献亭 on 15/5/2.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BaseViewController.h"
#import "PureLayout.h"

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

  //处理UIViewController的可视区域的高度
  if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
    CGRect contentRect = self.view.frame;

    //减去导航条的高度
    if (!self.navigationController.navigationBarHidden) {
      contentRect.size.height -=self.navigationController.navigationBar.frame.size.height;
      contentRect.origin.y +=self.navigationController.navigationBar.frame.size.height;

      //减去状态栏的高度
      if (![UIApplication sharedApplication].statusBarHidden) {
        contentRect.size.height -=[UIApplication sharedApplication].statusBarFrame.size.height;
        contentRect.origin.y +=[UIApplication sharedApplication].statusBarFrame.size.height;
      }
    }

    //减去tabBar的高度
    if ((self.tabBarController != nil) &&
        !self.tabBarController.hidesBottomBarWhenPushed) {
      contentRect.size.height = contentRect.size.height -self.tabBarController.tabBar.frame.size.height;
    }

    self.view.frame = contentRect;
  }
}

-(void)pushViewController:(Class)class object:(id)sendObject{
    if (![class isSubclassOfClass:[BaseViewController class]]&&![class isSubclassOfClass:[BaseTableViewController class]]) {
        return;
    }
    
    BaseViewController *vc=[class new];
    vc.sendObject=sendObject;
    [self.navigationController pushViewController:vc animated:YES];
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

-(UIBarButtonItem *)createButtonItem:(NSString*)imageName{
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageRight = [UIImage imageNamed:imageName];
    rightButton.frame = CGRectMake(0, 0, 30, imageRight.size.height);
    [rightButton setImage:imageRight forState:UIControlStateNormal];
    rightButton.backgroundColor = [UIColor clearColor];
    return [[UIBarButtonItem alloc] initWithCustomView:rightButton];
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
