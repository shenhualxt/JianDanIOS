//
// Created by 刘献亭 on 15/8/31.
// Copyright (c) 2015 刘献亭. All rights reserved.
//

#import "LeftMenu.h"

@implementation LeftMenu
- (instancetype)initWithImageName:(NSString *)imageName menuName:(NSString *)menuName {
    self = [super init];
    if (self) {
        self.imageName = imageName;
        self.menuName = menuName;
    }

    return self;
}

+ (instancetype)menuWithImageName:(NSString *)imageName menuName:(NSString *)menuName {
    return [[self alloc] initWithImageName:imageName menuName:menuName];
}

@end