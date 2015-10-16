//
//  NSString+Date.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/26.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

@property(strong,nonatomic) NSString *dateFormat;

-(NSString *)deltaTimeToNow;

- (nullable NSDate *)dateFromString;

+(NSString *)stringWithKey:(char *)key value:(int)value;

@end
