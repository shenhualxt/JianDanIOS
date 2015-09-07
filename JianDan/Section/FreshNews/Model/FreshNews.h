//
//  FreshNews.h
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Tags : NSObject

@property(nonatomic,assign) int id;
@property(nonatomic,strong) NSString *slug;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,assign) int post_count;

@end

@interface Author : NSObject

@property(nonatomic,strong) NSString *slug;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,assign) int id;
@property(nonatomic,strong) NSString *nickname;
@property(nonatomic,strong) NSString *last_name;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *first_name;

@end

@interface Custom_fields : NSObject

@property(nonatomic,strong) NSArray *thumb_c;
@property(nonatomic,strong) NSURL *thumb_m;
@property(nonatomic,strong) NSArray *views;
@property(nonatomic,strong) NSString *viewsCount;
@end

@interface Posts : NSObject

@property(nonatomic,strong) Author *author;
@property(nonatomic,strong) Custom_fields *custom_fields;
@property(nonatomic,assign) int id;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *date;
@property(nonatomic,assign) int comment_count;
@property(nonatomic,strong) NSArray *tags;
@property(nonatomic,strong) NSString *url;

@end

@interface FreshNews : NSObject

@property(nonatomic,strong) NSString *status;
@property(nonatomic,assign) int pages;
@property(nonatomic,assign) int count_total;
@property(nonatomic,assign) int count;
@property(nonatomic,strong) NSMutableArray *posts;

@end
