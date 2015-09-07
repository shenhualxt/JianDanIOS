//
//  NSCodingTools.h
//  CarManager
//
//  Created by 刘献亭 on 15/4/27.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCodingTools : NSObject

+ (void)save:(id)object;

+ (id)readUserInfo:(Class)aClass;
+ (void)deleteFile:(Class)aClass;
@end
