//
//  BaseViewController.h
//  CarManager
//
//  Created by 刘献亭 on 15/3/21.
//  Copyright (c) 2015年 David. All rights reserved.
//
@interface BaseViewController : UIViewController <UITextFieldDelegate>

@property(nonatomic,strong) id sendObject;

@property(nonatomic,strong) id resultObject;

-(void)pushViewController:(Class)class object:(id)sendObject;

-(void)popViewController:(Class)class object:(id)sendObject;

- (void)BackClick;

- (void)initBackGround;

- (instancetype)initWithSendObject:(id)sendObject;

+ (instancetype)controllerWithSendObject:(id)sendObject;


-(UIBarButtonItem *)createButtonItem:(NSString*)imageName;

-(void)whenNetErrorHappened:(NSString *)tipText command:(RACCommand *)command;

@end
