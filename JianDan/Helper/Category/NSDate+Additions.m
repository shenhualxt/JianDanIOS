//
//  NSDate+Additions.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/21.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSString *)toString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    
    NSString *destDateString = [dateFormatter stringFromDate:self];
    
    return destDateString;
    
}

@end
