//
//  CacheTools.m
//  CarManager
//
//  Created by 刘献亭 on 15/4/26.
//  Copyright (c) 2015年 David. All rights reserved.
//
#import "CacheTools.h"
#import "FMDB.h"
#import "NSErrorHelper.h"

NSString *const CacheToolsDomain = @"http://CacheTools";

static NSString *dbName = @"jiandan.sqlite";

static NSInteger pageNum = 24;

@interface CacheTools()

@property (strong,nonatomic) NSMutableArray *tableNameArray;

@property (strong,nonatomic) FMDatabaseQueue *queue;

@end

@implementation CacheTools


DEFINE_SINGLETON_IMPLEMENTATION(CacheTools)

- (void)setUp {
    _tableNameArray=[NSMutableArray array];
    _queue = [FMDatabaseQueue databaseQueueWithPath:[self getPath:dbName] flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
}

- (RACSignal *)read:(Class)clazz {
    return [self read:clazz page:0 tableName:nil];
}

- (RACSignal *)read:(Class)clazz page:(NSInteger)page {
    return [self read:clazz page:page tableName:nil];
}

- (RACSignal *)read:(NSInteger)page tableName:(NSString *)tableName {
    return [self read:nil page:page tableName:tableName];
}

- (RACSignal *)read:(Class)clazz page:(NSInteger)page tableName:(NSString *)tableName {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    if (!tableName) {
        tableName = [NSString stringWithFormat:@"%@", clazz];
    }
    @weakify(self)
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (page < 0) {
            [subscriber sendError:[self createError:@"page不能小于0" tableName:tableName]];
            return nil;
        };
        if (!_queue) {
            [self createError:@"create database queue failed" tableName:tableName];
            [subscriber sendError:nil];
            return nil;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                if (![self isTableExist:tableName database:db]) {
                    [subscriber sendCompleted];
                    return;
                }

                //拼接sql语句
                RACTuple *turple = [self getSelectSqlTextWith:page tableName:tableName database:db];

                if (![turple.first integerValue]) {
                    LogBlue(@"%@", @"没有更多的缓存数据");
                    [subscriber sendError:[NSErrorHelper createErrorWithErrorInfo:@"没有更多的缓存数据" domain:CacheToolsDomain]];
                    return;
                }

                //开始查询
                NSString * querySql = turple.second;
                FMResultSet *resultSet = [db executeQuery:querySql];

                //遍历查询结果，放入数组中
                NSMutableArray *infoArray = [NSMutableArray array];
                while (resultSet.next) {
                    @autoreleasepool {
                        NSData *data = [resultSet objectForColumnName:[NSString stringWithFormat:@"%@_dict", tableName]];
                        NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                        [infoArray addObject:obj];
                    }
                }

                if (infoArray.count == 0) {
                    [self createError:@"没有从数据库中取到数据" tableName:tableName];
                }
                [resultSet close];
                [subscriber sendNext:infoArray];
                [subscriber sendCompleted];
            }];
        });

        return nil;
    }] subscribeOn:scheduler] deliverOnMainThread];
}

- (NSError *)createError:(NSString *)tipInfo tableName:(NSString *)tableName {
    tipInfo = [NSString stringWithFormat:@"%@表_%@", tableName, tipInfo];
    LogBlue(@"%@", tipInfo);
    return [NSErrorHelper createErrorWithErrorInfo:tipInfo domain:CacheToolsDomain];
}

/**
 * 分页和不分页的情况
 */
- (RACTuple *)getSelectSqlTextWith:(NSInteger)page tableName:(NSString *)tableName database:(FMDatabase *)db {
    NSMutableString *querySql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@_idstr DESC", tableName, tableName];
    NSInteger length = pageNum;
    if (page != 0) {//需要分页
        NSInteger totalCount = [self getTableItemCount:tableName database:db];//数据库中的行数
        NSInteger start = (page - 1) * pageNum;

        if (totalCount <= pageNum) {//小于20条数据
            length = totalCount;
        } else if (totalCount <= page * pageNum) {//最后几条数据
            length = totalCount - (page - 1) * pageNum;
        }
        if (length <= 0) {
            //数据取完了
            length = 0;
        }
        // 实现分页
        [querySql appendFormat:@" limit %ld offset %ld", (long)length, (long)start];
    }
    return RACTuplePack(@(length), querySql);
}

- (void)save:(NSArray *)objectArray sortArgument:(NSString *)idStr {
    [[self racSave:objectArray sortArgument:idStr tableName:nil] subscribeError:^(NSError *error) {
        LogBlue(@"%@", error);
    }];
}

- (void)save:(NSArray *)objectArray sortArgument:(NSString *)idStr tableName:(NSString *)tableName {
    [[self racSave:objectArray sortArgument:idStr tableName:tableName] subscribeError:^(NSError *error) {
        LogBlue(@"%@", error);
    }];
}

- (RACSignal *)racSave:(NSArray *)objectArray sortArgument:(NSString *)idStr {
    return [self racSave:objectArray sortArgument:idStr tableName:nil];
}

// 向数据库中存数据
- (RACSignal *)racSave:(NSArray *)objectArray sortArgument:(NSString *)idStr tableName:(NSString *)tableName {
    if (![self.tableNameArray containsObject:tableName]) {
        [self.tableNameArray addObject:tableName];
    }
    if (!objectArray.count) return [RACSignal empty];
    //创建表格
    Class clazz = [objectArray[0] class];
    if (!tableName) {
        tableName = [NSString stringWithFormat:@"%@", clazz];
    }
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        //数据异常时
        if (!objectArray || ![objectArray isKindOfClass:[NSArray class]] || ![objectArray count]) {
            [subscriber sendError:[self createError:@"缓存数据类型不正确" tableName:tableName]];
            return nil;
        }

        //存入数据
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
            [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                if (![self createTable:tableName database:db]) {
                    //创建表失败
                    [subscriber sendError:[self createError:@"创建表失败" tableName:tableName]];
                    return;
                }

                NSMutableArray *temArray = [objectArray mutableCopy];
                [temArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                    @autoreleasepool {
                        //如果已经有了,就不在存入
                        NSString * querySql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@_idstr=%@",
                                                                         tableName, tableName, [obj valueForKey:idStr]];
                        FMResultSet *resultSet = [db executeQuery:querySql];
                        if (resultSet.next) {
                            [resultSet close];
                            return;
                        }
                        [resultSet close];
                        //数据库中没有，存入
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
                        NSString * updateSql = [NSString stringWithFormat:@"INSERT INTO %@ (%@_idstr, " @"%@_dict) VALUES (?, ?);",
                                                                          tableName, tableName, tableName];
                        BOOL success = [db executeUpdate:updateSql, [obj valueForKey:idStr], data];
                        if (!success) {
                            LogBlue(@"%@_插入数据失败", tableName);
                        }
                    }

                }];

                [subscriber sendNext:objectArray];
                [subscriber sendCompleted];
            }];

        });
        return nil;
    }];
}


// 数据库存储路径(内部使用)
- (NSString *)getPath:(NSString *)dbName {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:dbName];
}

// 获得表的数据条数
- (NSInteger)getTableItemCount:(NSString *)tableName database:(FMDatabase *)db {
    NSString * sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *rs = [db executeQuery:sqlstr];
    while ([rs next]) {
        NSInteger tableItemCount = [rs intForColumn:@"count"];
        [rs close];
        return tableItemCount;
    }
    [rs close];
    return 0;
}


// 创建表
- (BOOL)createTable:(NSString *)tableName database:(FMDatabase *)db {
    NSString * updateSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ "
                                                              @"(id integer PRIMARY KEY "
                                                              @"AUTOINCREMENT,%@_idstr BIGINT NOT "
                                                              @"NULL, %@_dict blob NOT NULL);",
                                                      tableName, tableName, tableName];
    if (![db executeUpdate:updateSql]) {
        LogBlue(@"Create db error!");
        LogBlue(@"Create db error!");
        return NO;
    }

    return YES;
}


//判断表是否存在
- (BOOL)isTableExist:(NSString *)tableName database:(FMDatabase *)db {
    FMResultSet *resultSet = [db executeQuery:@"select count(*) as 'count' from sqlite_master "
                                                      "where type ='table' and name = ?", tableName];
    while ([resultSet next]) {
        BOOL isExist = [resultSet intForColumn:@"count"];
        [resultSet close];
        return isExist;
    }
    [resultSet close];
    return NO;
}

// 删除表
- (BOOL) deleteTable:(NSString *)tableName database:(FMDatabase *)db
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![db executeUpdate:sqlstr])
    {
        NSLog(@"Delete table error!");
        return NO;
    }
    
    return YES;
}

// 清除表
- (BOOL) eraseTable:(NSString *)tableName database:(FMDatabase *)db
{
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![db executeUpdate:sqlstr])
    {
        NSLog(@"Erase table error!");
        return NO;
    }
    
    return YES;
}


-(void)clearDatabase{
    WS(ws)
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (NSString *tableName in ws.tableNameArray) {
                 [ws deleteTable:tableName database:db];
            }
            [ws.tableNameArray removeAllObjects];
        }];
    });
}

// 删除数据库文件
- (void)deleteDatabse {
    BOOL success;
    NSError * error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // delete the old db.
    if ([fileManager fileExistsAtPath:[self getPath:dbName]]) {
        success = [fileManager removeItemAtPath:[self getPath:dbName] error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
        }
    }
}

//获得数据库大小（仅一个数据库的情况）
- (CGFloat)getSize {
    CGFloat totalSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self getPath:dbName]]) {
        NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[self getPath:dbName] error:nil];
        totalSize += [attrs fileSize];
    }
    return totalSize;
}


@end
