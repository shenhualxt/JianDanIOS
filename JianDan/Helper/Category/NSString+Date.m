//
//  NSString+Date.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/26.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "NSString+Date.h"
#import "NSDate+MJ.h"

//static NSDateFormatter *formatter;

static char formatterKey;
static char dateFormatKey;

@interface NSString ()

@property(strong,nonatomic) NSDateFormatter *formatter;

@end

@implementation NSString (Date)

//int min value:-2147483648
//int max value:2147483647
+(NSString *)stringWithInt:(NSInteger)i
{
    char c[12];
    sprintf(c, "%d", (int)i);
    return [NSString stringWithUTF8String:c];
}

+(NSString *)stringWithKey:(char *)key value:(int)value
{
    char cString[16];
    sprintf(cString,"%s%d",key,value);
    return  [NSString stringWithUTF8String:cString];
}



+(NSString *)stringWithFloat:(float)f andPrecision:(NSInteger)p
{
    char c[16];//最长？
    
    char pre[16];
    sprintf(pre, "%%.%f",(float)p);
    
    sprintf(c, pre,f);
    return [NSString stringWithUTF8String:c];
}


-(void)setDateFormat:(NSString *)dateFormat{
    objc_setAssociatedObject(self, &dateFormatKey, dateFormat, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)dateFormat{
    return objc_getAssociatedObject(self, &dateFormatKey);
}

-(void)setFormatter:(NSDateFormatter *)formatter{
    if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            // 2015-09-29T14:52:58+08:00
//            formatter.dateFormat=@"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            formatter.dateFormat=self.dateFormat?: @"yyyy-MM-dd HH:mm:ss";
            //真机调试的时候，必须加上这句
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        }
    objc_setAssociatedObject(self, &formatterKey, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSDate *)dateFromString{
    [self setFormatter:nil];
     NSDateFormatter *formatter=objc_getAssociatedObject(self, &formatterKey);
    return [formatter dateFromString:self];
}


-(NSString *)deltaTimeToNow{
    //原始数据：2015-09-15 13:16:14  --》3 hours ago
    [self setFormatter:nil];
    NSDateFormatter *formatter=objc_getAssociatedObject(self, &formatterKey);
    NSDate *createDate=[formatter dateFromString:self];
    
    //今年之前
    if (!createDate.isThisYear) {
        formatter.dateFormat=@"yyyy-MM-dd";
        return [formatter stringFromDate:createDate];
    }
    //今天之前
    if(!createDate.isToday){
        formatter.dateFormat = @"MM-dd HH:mm";
        return [formatter stringFromDate:createDate];
    }
    
    //今天
    NSDateComponents *components=[createDate deltaWithNow];
    //1小时前
    if (components.hour>1) {
        return [NSString stringWithFormat:@"%ld hours ago",(long)components.hour];
    }
    //1~59分钟之前
    if(components.minute>=1){
        return [NSString stringWithFormat:@"%ld mins ago",(long)components.minute];
    }
    //1分钟之内
    return @"刚刚";
}

@end
