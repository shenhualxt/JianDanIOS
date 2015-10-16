//
//  Vote.h
//  JianDan
//
//  Created by 刘献亭 on 15/10/16.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vote : NSObject

@property (nonatomic, assign) NSInteger vote_positive;

@property (nonatomic, strong) NSString *post_id;

@property (nonatomic, assign) NSInteger vote_negative;

@end
