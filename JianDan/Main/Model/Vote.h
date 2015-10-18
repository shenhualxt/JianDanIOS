//
//  Vote.h
//  JianDan
//
//  Created by 刘献亭 on 15/10/16.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Vote <NSObject>

@required
-(NSString *)getPost_id;

-(NSInteger)encreaseVote_negative;

-(NSInteger)encreaseVote_positive;

@end
