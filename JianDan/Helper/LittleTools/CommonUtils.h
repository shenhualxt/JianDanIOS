//
//  CommonUtils.h
//  CarWin
//
//  Created by 李昀 on 15/3/6.
//  Copyright (c) 2015年 李昀. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+ (UIImage *) createImageWithColor: (UIColor *) color;

+(void)call:(NSString *)num text:(NSString *)text;
+(void)setLastCellSeperatorToLeft:(UITableViewCell*)cell;

+(float) heightForString:(NSString *)value fontSize:(UIFont *)fontSize andWidth:(float)width;

+ (UIColor *)randomColor;
+ (NSString *)getBuild;

+ (NSString *)sha1:(NSString *)str;
+ (NSString *)md5Hash:(NSString *)str;

+ (NSString *)getTimerWihtTimerStamp:(NSString *)stringTimer;
+ (NSString *)deviceString;
+ (UIViewController *)viewController:(UIView *)view;
+ (int)getRandomNumber:(int)from to:(int)to;
//+ (void)getDeviceInfo4Umeng;
+ (int)numOfDaysFrom:(NSString *)dateStr;
+ (int)numOfDaysFrom:(NSString *)dateStr to:(NSString *)toDate;
+ (int)numOfDaysFromDate:(NSDate *)fromdate;
+ (BOOL)isChineseWith:(unichar)c;

+ (BOOL)isAllowedNotification;

+ (void)getKeyFromDictionary:(NSDictionary *)dic;

@end
