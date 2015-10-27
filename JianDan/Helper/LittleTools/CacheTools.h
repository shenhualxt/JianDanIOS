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

- (void)clearDatabase;

- (void)save:(NSArray *)objectArray sortArgument:(NSString *)idStr;

- (void)save:(NSArray *)objectArray sortArgument:(NSString *)idStr tableName:(NSString *)tableName;

- (RACSignal *)racSave:(NSArray *)objectArray sortArgument:(NSString *)idStr;

- (RACSignal *)racSave:(NSArray *)objectArray sortArgument:(NSString *)idStr tableName:(NSString *)tableName;

- (RACSignal *)racRead:(Class)clazz;

- (RACSignal *)racRead:(Class)clazz page:(NSInteger)page;

- (RACSignal *)racRead:(Class)clazz page:(NSInteger)page tableName:(NSString *)tableName;

- (CGFloat)getSize;

@end
