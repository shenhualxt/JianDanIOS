//
//  CommonUtils.h
//  CarWin
//
//  Created by 李昀 on 15/3/6.
//  Copyright (c) 2015年 李昀. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonUtils : NSObject

+ (CGSize)getStringRect:(NSString *)aString;

+ (BOOL)isMatch:(NSString *)strPlace regex:(NSString *)regex;

+ (BOOL)isChinese:(const NSString *)newText;

+ (BOOL)isSpecialHansChar:(const NSString *)text;

+ (BOOL)isHansInput:(UITextView *)textView;

+ (UITextPosition *)isHasHighlightText:(UITextView *)textView;

+ (NSInteger)convertToInt:(NSString *)strtemp;

+ (NSInteger)countHansNum:(NSString *)text;

+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (void)setLastCellSeperatorToLeft:(UITableViewCell *)cell;

+ (float)heightForString:(NSString *)value fontSize:(UIFont *)fontSize andWidth:(float)width;

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
