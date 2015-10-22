//
//  PicturesController.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/21.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsController.h"

typedef NS_ENUM(NSInteger, ControllerType) {
    controllerTypeBoredPictures = 1,
    controllerTypeSisterPictures,
    controllerTypeJoke,
};

@interface PicturesController : FreshNewsController

- (instancetype)initWithControllerType:(ControllerType)controllerType;

@end
