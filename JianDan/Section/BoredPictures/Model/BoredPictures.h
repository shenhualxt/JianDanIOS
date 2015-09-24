//
//  BoredPictures.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/19.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoredPictures : NSObject

@property (nonatomic, copy) NSString *comment_date;

@property (nonatomic, copy) NSString *comment_approved;

@property (nonatomic, copy) NSString *comment_author_url;

@property (nonatomic, copy) NSString *comment_parent;

@property (nonatomic, copy) NSString *comment_subscribe;

@property (nonatomic, copy) NSString *comment_author;

@property (nonatomic, copy) NSString *vote_positive;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *comment_reply_ID;

@property (nonatomic, copy) NSString *comment_author_email;

@property (nonatomic, copy) NSString *text_content;

@property (nonatomic, copy) NSString *comment_type;

@property (nonatomic, copy) NSString *comment_ID;

@property (nonatomic, copy) NSString *comment_author_IP;

@property (nonatomic, strong) NSArray *pics;

@property (nonatomic, copy) NSString *comment_agent;

@property (nonatomic, copy) NSString *comment_content;

@property (nonatomic, copy) NSString *vote_negative;

@property (nonatomic, strong) NSArray *videos;

@property (nonatomic, copy) NSString *comment_post_ID;

@property (nonatomic, copy) NSString *comment_date_gmt;

@property (nonatomic, copy) NSString *comment_karma;

//新添加
@property (nonatomic, copy) NSString *comment_count;

@property (nonatomic, strong) NSString *comment_time;

@property (nonatomic, strong) NSString *date;

@end

