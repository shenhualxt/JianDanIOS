//
//  AFNetWorkUtils.h
//  CarManager
//
//  Created by 李昀 on 15/3/9.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface AFNetWorkUtils : NSObject
+ (RACSignal *)post2racWthURL:(NSString *)url params:(NSDictionary *)params;
+ (RACSignal *)racPOSTWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz;

+ (RACSignal *)get2racWthURL:(NSString *)url;
+ (RACSignal *)racGETWithURL:(NSString *)url class:(Class)clazz;
@end
