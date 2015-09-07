//
//  NSCodingTools.m
//  CarManager
//
//  Created by 刘献亭 on 15/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import "NSCodingTools.h"

@implementation NSCodingTools

+ (void)save:(id)object
{
    // 2.1.获得Documents的全路径
    NSString* doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 2.2.获得文件的全路径
    NSString* path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", [object class]]];
    // 2.3.将对象归档
    [NSKeyedArchiver archiveRootObject:object toFile:path];
}

+ (id)readUserInfo:(Class)aClass
{
    // 1.获得Documents的全路径
    NSString* doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 2.获得文件的全路径
    NSString* path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", aClass]];
    // 3.从文件中读取对象
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

+ (void)deleteFile:(Class)aClass{
  NSFileManager* fileManager=[NSFileManager defaultManager];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
  
  //文件名
  NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", aClass]];
  BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
  if (!blHave) {
    return ;
  }else {
    [fileManager removeItemAtPath:uniquePath error:nil];
  }
}



@end
