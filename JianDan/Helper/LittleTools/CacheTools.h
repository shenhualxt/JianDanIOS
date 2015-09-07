//
//  CacheTools.h
//
//  Created by 刘献亭 on 15/4/26.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheTools : NSObject

+ (CacheTools *)sharedCacheTools;

- (void)deleteDatabse;

- (void)save:(NSArray *)objectArray sortArgument:(NSString *)idStr;

- (RACSignal *)read:(Class)clazz page:(NSInteger)page;

@end
