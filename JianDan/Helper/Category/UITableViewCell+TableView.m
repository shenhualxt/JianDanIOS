//
//  UITableViewCell+TableView.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/22.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "UITableViewCell+TableView.h"

@implementation UITableViewCell (TableView)

- (UITableView *)tableView
{
    UIView *tableView = self.superview;
    
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    
    return (UITableView *)tableView;
}

-(UIViewController *)controller{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
