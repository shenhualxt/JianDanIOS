//
//  NSErrorHelper.h
//  JianDan
//
//  Created by 刘献亭 on 15/10/15.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const customErrorCode = 0;

static NSString *const customErrorInfoKey = @"customErrorInfoKey";

@interface NSErrorHelper : NSObject

+ (NSString *)handleErrorMessage:(NSError *)error;

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo;

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code;

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain;

+ (NSError *)createErrorWithErrorInfo:(NSString *)customErrorInfo domain:(NSString *)domain code:(NSInteger)code;

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo;

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain;

+ (NSError *)createErrorWithUserInfo:(NSDictionary *)userInfo domain:(NSString *)domain code:(NSInteger)code;

@end
