//
//  NSDictionary+JSONString.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/8.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONString)

-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint;

@end
