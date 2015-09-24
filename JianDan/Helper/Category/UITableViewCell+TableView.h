//
//  UITableViewCell+TableView.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/22.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (TableView)

- (UITableView *)tableView;

-(UIViewController *)controller;

@end
