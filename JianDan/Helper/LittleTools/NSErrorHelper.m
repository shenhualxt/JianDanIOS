//
//  NSErrorHelper.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/15.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "NSErrorHelper.h"

NSString * const errorHelperDomain=@"http://NSErrorHelper";

@implementation NSErrorHelper

+ (NSString *)handleErrorMessage:(NSError *)error {
    NSString *result = nil;
    switch (error.code) {
        case customErrorCode://0 自定义错误
            result=error.userInfo[customErrorInfoKey];
            break;
        case kCFURLErrorTimedOut://-1001
            result = @"服务器连接超时";
            break;
        case kCFURLErrorBadServerResponse://-1011
            result = @"请求无效";
            break;
        case kCFURLErrorNotConnectedToInternet: //-1009 @"似乎已断开与互联网的连接。"
        case kCFURLErrorCannotDecodeContentData://-1016 cmcc 解析数据失败
            result = @"网络好像断开了...";
            break;
        case kCFURLErrorCannotFindHost: //-1003 @"未能找到使用指定主机名的服务器。"
            result = @"服务器内部错误";
            break;
        case kCFURLErrorNetworkConnectionLost: //-1005
            result = @"网络连接已中断";
            break;
        default:
            result =@"其他错误";
            LogBlue(@"其他错误 error:%@", error);
            break;
    }
    
    return result;
}

+(NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo{
    return [NSError errorWithDomain:errorHelperDomain code:customErrorCode userInfo:@{customErrorInfoKey:customErrorInfo}];
}

+(NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain{
    return [NSError errorWithDomain:domain code:customErrorCode userInfo:@{customErrorInfoKey:customErrorInfo}];
}

+(NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain code:(NSInteger)code{
    return [NSError errorWithDomain:domain code:code userInfo:@{customErrorInfoKey:customErrorInfo}];
}

+(NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code{
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

+(NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo{
    return [NSError errorWithDomain:errorHelperDomain code:customErrorCode userInfo:userInfo];
}

+(NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain{
    return [NSError errorWithDomain:domain code:customErrorCode userInfo:userInfo];
}

+(NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain code:(NSInteger)code{
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

@end
