//
//  BoredPictures.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/19.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "BoredPictures.h"
#import "NSDate+MJ.h"

static NSDateFormatter *formatter;

@implementation BoredPictures

+(NSDateFormatter *)formatter{
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    return formatter;
}

- (NSString *)date {
    //  "2015-08-30 12:40:26"  ---> NSDate --> 1363948516
    NSDate* date = [[BoredPictures formatter] dateFromString:_comment_date];
    return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
}

+(NSDictionary *)objectClassInArray{
    return @{@"pics":[NSString class]};
}
MJCodingImplementation

-(NSString *)text_content{
    return [_text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
}

-(NSString *)comment_time{
    //原始数据：2015-09-15 13:16:14  --》3 hours ago
    NSDateFormatter *formatter=[NSDateFormatter new];
    formatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    //真机调试的时候，必须加上这句
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDate *createDate=[formatter dateFromString:_comment_date];
    
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


