//
//  LeftMenuController.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "LeftMenuController.h"
#import "LeftMenu.h"
#import "LeftMenuCell.h"
#import "AppDelegate.h"
#import "FreshNewsController.h"
#import "UIViewController+MMDrawerController.h"

@interface LeftMenuController ()

@property(nonatomic, strong) NSMutableArray *menuArray;

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindingTableView];
    [self addSettingButton];
}

- (void)bindingTableView {
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    RACCommand *menuCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [delegate replaceContentViewController:[FreshNewsController new]];
        return [RACSignal empty];
    }];
    [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:RACObserve(self, menuArray) selectionCommand:menuCommand templateCellClass:[LeftMenuCell class]];
}

- (void)addSettingButton {
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height - 64, 240, 40)];
    [self.tableView addSubview:settingButton];
    settingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIEdgeInsets contentEdgeInsets = settingButton.contentEdgeInsets;
    contentEdgeInsets.left = 30;
    settingButton.contentEdgeInsets = contentEdgeInsets;
    UIEdgeInsets imageEdgeInsets = settingButton.imageEdgeInsets;
    imageEdgeInsets.left = -15;
    settingButton.imageEdgeInsets = imageEdgeInsets;
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton setImage:[UIImage imageNamed:@"ic_settings_white_24dp"] forState:UIControlStateNormal];
    [settingButton setBackgroundImage:[CommonUtils createImageWithColor:RGBA(255, 255, 255, 0.6)] forState:UIControlStateHighlighted];
    [[settingButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        MMDrawerController *drawerController = self.mm_drawerController;
        [drawerController.navigationController pushViewController:[FreshNewsController new] animated:YES];
    }];
}

- (NSMutableArray *)menuArray {
    if (!_menuArray) {
        _menuArray = [NSMutableArray array];
        NSArray *imageNameArray = @[@"ic_explore_white_24dp", @"ic_mood_white_24dp", @"ic_local_florist_white_24dp", @"ic_chat_white_24dp", @"ic_movie_white_24dp"];
        NSArray *menuNameArray = @[@"新鲜事", @"无聊图", @"妹子图", @"段子", @"小电影"];
        for (int i = 0; i < [menuNameArray count]; ++i) {
            LeftMenu *menu = [LeftMenu menuWithImageName:imageNameArray[i] menuName:menuNameArray[i]];
            [_menuArray addObject:menu];
        }
    }
    return _menuArray;
}

@end
