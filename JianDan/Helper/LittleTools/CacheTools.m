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
         sharedCacheTools = [[super allocWithZone:NULL] init];
        _db = [FMDatabase databaseWithPath:[self getPath:dbName]];
        queue = [FMDatabaseQueue databaseQueueWithPath:[self getPath:dbName]];
    });
    return sharedCacheTools;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedCacheTools];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(void)setUp{
    
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
    // 异常数据
    if (page < 0) {
        return nil;
    }
    NSString *tableName = [NSString stringWithFormat:@"%@", clazz];
    // 打开数据库
    if (![_db open]) {
        [_db close];
        LogBlue(@"数据库打开失败");
        [_db logsErrors];
    }
    //如果表不存在，直接返回nil
    if (![self isTableExist:tableName]) {
        return nil;
    }
    //拼接sql语句
    NSString *querySql = [self getSelectSqlTextWith:page tableName:tableName];
    if (!querySql) {
        return nil;
    }
    //开始查询
    FMResultSet *resultSet = [_db executeQuery:querySql];

    //遍历查询结果，放入数组中
    NSMutableArray *infoArray = [NSMutableArray array];
    while (resultSet.next) {
        @autoreleasepool {
            NSData *data = [resultSet objectForColumnName:[NSString stringWithFormat:@"%@_dict", tableName]];
            NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [infoArray addObject:obj];
        }
    }
    return infoArray;
}

/**
 * 分页和不分页的情况
 */
- (NSMutableString *)getSelectSqlTextWith:(NSInteger)page tableName:(NSString *)tableName {
    NSMutableString *querySql =[NSMutableString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@_idstr DESC", tableName, tableName];
    if (page == 0) {//需要分页
        NSInteger totalCount = [self getTableItemCount:tableName];//数据库中的行数
        NSInteger start = (page - 1) * pageNum;
        NSInteger length = pageNum;
        if (totalCount <= pageNum) {//小于20条数据
            length = totalCount;
        } else if (totalCount <= page * pageNum) {//最后几条数据
            length = totalCount - (page - 1) * pageNum;
        }
        if (length <= 0) {
            return nil;
        }
        // 实现分页
        [querySql appendFormat:@" limit %ld offset %ld", length, start];
    }
    return querySql;
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
    //数据异常时
    if (!objectArray || ![objectArray isKindOfClass:[NSArray class]] || ![objectArray count]) {
        return;
    }
    //打开数据库
    if (![_db open]) {
        [_db close];
        [_db logsErrors];
        LogBlue(@"数据库打开失败");
        return;
    }
    //创建表格
    Class clazz = [objectArray[0] class];
    NSString *tableName = [NSString stringWithFormat:@"%@", clazz];
    if (![self createTable:tableName]) {
        //创建表失败
        return;
    }
    //存入数据
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
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
                    //*rollback=YES;
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
- (NSInteger)getTableItemCount:(NSString *)tableName {
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *rs = [_db executeQuery:sqlstr];
    while ([rs next]) {
        return [rs intForColumn:@"count"];
    }
    return 0;
}


// 创建表
- (BOOL)createTable:(NSString *)tableName {
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
