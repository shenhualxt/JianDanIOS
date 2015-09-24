//
//  BaseTableViewController.h
//  CarManager
//
//  Created by 刘献亭 on 15/5/2.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController : UITableViewController
@property(nonatomic,strong) id sendObject;
@property(nonatomic,strong) id resultObject;

-(void)pushViewController:(Class)class object:(id)sendObject;

-(void)popViewController:(Class)class object:(id)resultObject;

-(instancetype)initWithSendObject:(id)sendObject;

+ (instancetype)controllerWithSendObject:(id)sendObject;


-(UIBarButtonItem *)createButtonItem:(NSString*)imageName;

-(void)whenNetErrorHappened:(NSString *)tipText command:(RACCommand *)command;

@end
