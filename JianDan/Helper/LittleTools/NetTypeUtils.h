//
//  NetTypeUtils.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/6.
//  Copyright (c) 2015 刘献亭. All rights reserved.
//
typedef NS_ENUM(NSInteger,NetType){
    NONet,
    WiFiNet,
    OtherNet,
};

@interface NetTypeUtils : NSObject

+(NetTypeUtils *)sharedNetTypeUtils;

- (void)startMonitoring;

@property (nonatomic, assign) NSInteger netType;

@end
