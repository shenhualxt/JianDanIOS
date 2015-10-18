//
//  VoteViewModel.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vote.h"

typedef NS_ENUM(NSInteger,VoteOption){
    XX,
    OO,
};

static NSString *result_xx_success=@"-1";
static NSString *result_oo_success=@"1";
static NSString *result_have_voted=@"0";

@interface VoteViewModel : NSObject

+(void)voteWithOption:(VoteOption)option vote:(id<Vote>)vote button:(UIButton *)button;

@end
