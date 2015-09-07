//
//  CacheTools.m
//  CarManager
//
//  Created by 刘献亭 on 15/4/26.
//  Copyright (c) 2015年 David. All rights reserved.
//
#import "CacheTools.h"
#import "FMDB.h"

@implementation CacheTools

//注意：数据库表名和模型名相同（如果同一种模型数据，需要缓存多次，需另行扩展）
static FMDatabase *_db;
static NSString *dbName = @"jiandan.sqlite";
static NSInteger pageNum = 20;

static CacheTools *sharedCacheTools = nil;
static dispatch_once_t pred;
static FMDatabaseQueue *queue;

+ (CacheTools *)sharedCacheTools {
    dispatch_once(&pred, ^{
        _db = [FMDatabase databaseWithPath:[self getPath:dbName]];
        sharedCacheTools = [[super allocWithZone:NULL] init];
        queue=[FMDatabaseQueue databaseQueueWithPath:[self getPath:dbName]];
    });
    return sharedCacheTools;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedCacheTools];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (RACSignal *)read:(Class)clazz page:(NSInteger)page {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    @weakify(self)
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        NSArray *objectArray = [self syncRead:clazz page:page];
        [subscriber sendNext:objectArray];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler] deliverOnMainThread];
}

//分页从数据库中取数据
- (NSArray *)syncRead:(Class)clazz page:(NSInteger)page {
    NSString *kTableName = [NSString stringWithFormat:@"%@", clazz];
    // 3.打开数据库
    if (![_db open]) {
        [_db close];
        LogBlue(@"数据库打开失败");
        [_db logsErrors];
    }
    //如果表不存在，直接返回nil
    if (![self isTableExist:kTableName]) {
        return nil;
    }

    // 创建数组缓存数据
    NSMutableArray *infoArray = [NSMutableArray array];

   NSInteger totalCount= [self getTableItemCount:kTableName];
    NSInteger start = (page - 1) * pageNum;
    NSInteger length = pageNum;
    if (totalCount <= pageNum) {//小于20条数据
        length = totalCount;
    } else if (totalCount <= page * pageNum) {//最后几条数据
        length = totalCount - (page - 1) * pageNum;
    }
   // 根据请求参数查询数据
    NSString *querySql = [NSString stringWithFormat:
            @"SELECT * FROM %@ ORDER BY %@_idstr DESC limit %ld offset %ld", kTableName, kTableName,(long)length,(long)start];
    FMResultSet *resultSet = [_db executeQuery:querySql];
    [_db logsErrors];
    // 遍历查询结果
    while (resultSet.next) {
        @autoreleasepool {
            NSData *data = [resultSet objectForColumnName:[NSString stringWithFormat:@"%@_dict", kTableName]];
            NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [infoArray addObject:obj];// 添加模型到数组中
        }
    }
    return infoArray;
}

- (void)save:(NSArray *)objectArray sortArgument:(NSString *)idStr {
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    @weakify(self)
    dispatch_async(concurrentQueue, ^{
        @strongify(self)
        [self syncSave:objectArray sortArgument:idStr];
    });
}


// 向数据库中存数据
- (void)syncSave:(NSArray *)objectArray sortArgument:(NSString *)idStr {
    if (!objectArray || ![objectArray isKindOfClass:[NSArray class]] || ![objectArray count]) {
        return;
    }
    //打开数据库
    if (![_db open]) {
        [_db close];
        LogBlue(@"数据库打开失败");
        [_db logsErrors];
        return;
    }
    Class clazz = [objectArray[0] class];
    //第一次的话创建表
    if (![self createTable:clazz]) {
        return;
    }

    [queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        //存入数据
        for (NSObject *obj in objectArray) {
            @autoreleasepool {
                //如果已经有了,就不在存入
                NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@_idstr=%@",
                                      clazz, clazz, [obj valueForKey:idStr]];
                FMResultSet *resultSet = [db executeQuery:querySql];
                if (resultSet.next) continue;
                
                //数据库中没有，存入
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];// 把dict字典对象序列化成NSData二进制数据
                NSString *updateSql = [NSString stringWithFormat:@"INSERT INTO %@ (%@_idstr, " @"%@_dict) VALUES (?, ?);",
                                       clazz, clazz, clazz];
                BOOL success = [db executeUpdate:updateSql, [obj valueForKey:idStr], data];
                if (!success) {
                    LogBlue(@"插入数据失败");
//                    *rollback=YES;
                }
            }
        }
       
    }];

}


// 数据库存储路径(内部使用)
+ (NSString *)getPath:(NSString *)dbName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:dbName];
}

// 获得表的数据条数
- (NSInteger)getTableItemCount:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *rs = [_db executeQuery:sqlstr];
    while ([rs next])
    {
        return [rs intForColumn:@"count"];
    }
    return 0;
}


// 创建表
- (BOOL)createTable:(Class)clazz {
    NSString *tableName = [NSString stringWithFormat:@"%@", clazz];
    NSString *updateSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ "
                                                             @"(id integer PRIMARY KEY "
                                                             @"AUTOINCREMENT,%@_idstr text NOT "
                                                             @"NULL, %@_dict blob NOT NULL);",
                                                     tableName, tableName, tableName];
    if (![_db executeUpdate:updateSql]) {
        NSLog(@"Create db error!");
        LogBlue(@"Create db error!");
        return NO;
    }

    return YES;
}


//判断表是否存在
- (BOOL)isTableExist:(NSString *)tableName {
    FMResultSet *resultSet = [_db executeQuery:@"select count(*) as 'count' from sqlite_master "
                                                       "where type ='table' and name = ?", tableName];
    while ([resultSet next]) {
        return [resultSet intForColumn:@"count"];
    }
    return NO;
}

// 删除数据库
- (void)deleteDatabse {
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // delete the old db.
    if ([fileManager fileExistsAtPath:[CacheTools getPath:dbName]]) {
        [_db close];
        success = [fileManager removeItemAtPath:[CacheTools getPath:dbName] error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
        }
    }
}


@end
