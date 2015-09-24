//
//  FreshNewsComment.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsComment.h"
#import "NSDate+MJ.h"

@implementation FreshNewsComment

@end
@implementation FreshNewsCommentPost

+ (NSDictionary *)objectClassInArray{
    return @{@"comments" : [Comments class]};
}

@end


@implementation Comments

-(NSString *)date{
    //原始数据：2015-09-15 13:16:14  --》3 hours ago
    NSDateFormatter *formatter=[NSDateFormatter new];
    formatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    //真机调试的时候，必须加上这句
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDate *createDate=[formatter dateFromString:_date];
    
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

-(CGFloat)nameWidth{
    return [_name sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}].width;
}

-(BOOL)isEqual:(Comments *)object{
    return object.id==self.id;
}
@end


