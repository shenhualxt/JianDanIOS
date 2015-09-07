//
//  CommonUtils.m
//  CarWin
//
//  Created by 李昀 on 15/3/6.
//  Copyright (c) 2015年 李昀. All rights reserved.
//

#import "CommonUtils.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CommonUtils

+ (UIImage *) createImageWithColor: (UIColor *) color
{
  CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);

  UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return theImage;
}


+(void)setLastCellSeperatorToLeft:(UITableViewCell*)cell
{
  if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
    [cell setSeparatorInset:UIEdgeInsetsZero];
  }

  if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    [cell setLayoutMargins:UIEdgeInsetsZero];
  }

  if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
    [cell setPreservesSuperviewLayoutMargins:NO];
  }
}

/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param andWidth 限制字符串显示区域的宽度
 @result float 返回的高度
 */
+(float) heightForString:(NSString *)value fontSize:(UIFont *)fontSize andWidth:(float)width
{
  CGSize sizeToFit = [value sizeWithFont:fontSize constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
  return sizeToFit.height;
}

+ (UIColor *)randomColor {
  static BOOL seeded = NO;
  if (!seeded) {
    seeded = YES;
    (time(NULL));
  }
  CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
  CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
  CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
  return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (NSString*)getBuild
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleVersion"];
}

/**
 *  自动生成字段工具
 *
 *  @param dic 接口的返回值
 */
+ (void)getKeyFromDictionary:(NSDictionary*)dic
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
      return;
    }
    NSMutableString* result = [NSMutableString string];
    int i = 0;
    for (NSString* key in dic) {
        i++;
        //普通类型
        NSString* type = @"";
        NSString* property = @"strong";
        NSString* isObject = @"*";
        //还是字典
        if ([dic[key] isKindOfClass:[NSDictionary class]]) {
            [self getKeyFromDictionary:dic[key]];
            type = key;
        }

        //是数组
        if ([dic[key] isKindOfClass:[NSArray class]]) {
          NSArray *array=dic[key];
            if (array.count!=0){
            [self getKeyFromDictionary:dic[key][0]];
            type = @"NSArray";
                          }
        }

        if ([dic[key] isKindOfClass:[NSNumber class]]) {
            type = @"int";
            property = @"assign";
            isObject = @"";
            NSString* value = [NSString stringWithFormat:@"%@", dic[key]];
            NSInteger location = [value rangeOfString:@"."].length;
            if (location > 0) {
                type = @"float";
            }
        }

        if ([dic[key] isKindOfClass:[NSString class]] || [dic[key] isKindOfClass:[NSNull class]]) {
            type = @"NSString";
        }

        [result appendString:[NSString stringWithFormat:@"@property(nonatomic,%@) %@ %@%@;\n", property, type, isObject, key]];
    }
    LogBlue(@"%@一共%d个字段", result, i);
}

+ (NSString*)sha1:(NSString*)str
{
    const char* cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData* data = [NSData dataWithBytes:cstr length:str.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

+ (NSString*)md5Hash:(NSString*)str
{
    const char* cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    NSString* md5Result = [NSString stringWithFormat:
                                        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                    result[0], result[1], result[2], result[3],
                                    result[4], result[5], result[6], result[7],
                                    result[8], result[9], result[10], result[11],
                                    result[12], result[13], result[14], result[15]];
    return md5Result;
}

+ (BOOL)isChineseWith:(unichar)c
{
    return c >= 0x4E00 && c <= 0x9FFF;
}

/**
 *  根据时间戳获取时间，这里长度-3了
 *
 *  @param stringTimer 时间
 *
 *  @return 时间戳
 */
+ (NSString*)getTimerWihtTimerStamp:(NSString*)stringTimer
{
    //    if ([stringTimer rangeOfString:@"-"].location > 0) {
    //        return stringTimer;
    //    }
    NSString* string = [stringTimer stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString* stringEnd = [string stringByReplacingOccurrencesOfString:@")/" withString:@""];

    if (stringEnd.length > 10) {
        stringEnd = [stringEnd substringToIndex:10];
    }

    NSDate* configDate = [NSDate dateWithTimeIntervalSince1970:stringEnd.intValue];
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //    NSInteger intervaldd = [zone secondsFromGMTForDate: configDate];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* returnTimerString = [formatter stringFromDate:configDate];
    return returnTimerString;
}

+ (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

/**
 *  通过View找到所在的Controller
 *
 *  @param view 所在的View
 *
 *  @return 要找的Controller
 */
+ (UIViewController*)viewController:(UIView*)view
{
    UIResponder* nextResponder = [view nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return (UIViewController*)nextResponder;
    }
    return nil;
}

/**
 *  check if user allow local notification of system setting
 *
 *  @return YES-allowed,otherwise,NO.
 */
+ (BOOL)isAllowedNotification
{
    //iOS8 check if user allow notification
    if ([self isSystemVersioniOS8]) { // system is iOS8
        UIUserNotificationSettings* setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    }
    else { //iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (UIRemoteNotificationTypeNone != type)
            return YES;
    }

    return NO;
}

/**
 *  check if the system version is iOS8
 *
 *  @return YES-is iOS8,otherwise,below iOS8
 */
+ (BOOL)isSystemVersioniOS8
{
    //check systemVerson of device
    UIDevice* device = [UIDevice currentDevice];
    float sysVersion = [device.systemVersion floatValue];

    if (sysVersion >= 8.0f) {
        return YES;
    }
    return NO;
}

//+ (void)getDeviceInfo4Umeng {
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if (cls && [cls respondsToSelector:deviceIDSelector]) {
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{ @"oid" : deviceID }
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//
//    LogBlue(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
//}

/**
 *  计算某日期到今天的天数
 *
 *  @param dateStr 2012-05-17 11:23:23(起止日期)
 *
 *  @return 天数
 */
+ (int)numOfDaysFrom:(NSString*)dateStr
{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];

    [format setDateFormat:@"yyyy-MM-dd"];

    NSDate* fromdate = [format dateFromString:dateStr];
    return [self numOfDaysFromDate:fromdate];
}

/**
 *  计算某日期到今天的天数
 *
 *  @param dateStr 2012-05-17 11:23:23(起止日期)
 *
 *  @return 天数
 */
+ (int)numOfDaysFromDate:(NSDate*)fromdate
{
    if (fromdate == nil) {
        return 0;
    }
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

    NSTimeZone* fromzone = [NSTimeZone systemTimeZone];

    NSInteger frominterval = [fromzone secondsFromGMTForDate:fromdate];

    NSDate* fromDate = [fromdate dateByAddingTimeInterval:frominterval];

    NSDate* date = [NSDate date];

    NSTimeZone* zone = [NSTimeZone systemTimeZone];

    NSInteger interval = [zone secondsFromGMTForDate:date];

    NSDate* localeDate = [date dateByAddingTimeInterval:interval];

    NSDateComponents* components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];

    int days = 0;
    if (components.year) {
        days = (int)components.year * 365;
    }

    if (components.month) {
        days += (int)components.month * 30;
    }

    if (components.day > 0) {
        days += (int)components.day;
    }

    return days;
}

+ (int)numOfDaysFrom:(NSString*)dateStr to:(NSString*)toDate
{
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

    NSDateFormatter* format = [[NSDateFormatter alloc] init];

    [format setDateFormat:@"yyyy-MM-dd"];

    NSDate* fromdate = [format dateFromString:dateStr];

    NSTimeZone* fromzone = [NSTimeZone systemTimeZone];

    NSInteger frominterval = [fromzone secondsFromGMTForDate:fromdate];

    NSDate* fromDate = [fromdate dateByAddingTimeInterval:frominterval];

    NSDate* date = [format dateFromString:toDate];

    NSTimeZone* zone = [NSTimeZone systemTimeZone];

    NSInteger interval = [zone secondsFromGMTForDate:date];

    NSDate* localeDate = [date dateByAddingTimeInterval:interval];

    NSDateComponents* components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];

    int days = 0;
    if (components.year) {
        days = (int)components.year * 365;
    }

    if (components.month) {
        days += (int)components.month * 30;
    }

    if (components.day > 0) {
        days += (int)components.day;
    }

    return days;
}

+ (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone1,1"])
        return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])
        return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])
        return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])
        return @"4";
    if ([deviceString isEqualToString:@"iPhone4,1"])
        return @"4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])
        return @"5";
    if ([deviceString isEqualToString:@"iPhone3,2"])
        return @"4";
    if ([deviceString isEqualToString:@"iPod1,1"])
        return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])
        return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])
        return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])
        return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])
        return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])
        return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])
        return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])
        return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])
        return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])
        return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}

@end
