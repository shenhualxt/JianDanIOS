//
// Created by 刘献亭 on 15/8/31.
// Copyright (c) 2015 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeftMenu :NSObject

@property(nonatomic,strong) NSString *imageName;
@property(nonatomic,strong) NSString *menuName;

- (instancetype)initWithImageName:(NSString *)imageName menuName:(NSString *)menuName;

+ (instancetype)menuWithImageName:(NSString *)imageName menuName:(NSString *)menuName;

@end