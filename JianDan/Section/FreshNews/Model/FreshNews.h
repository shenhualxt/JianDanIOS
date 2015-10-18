//
//  FreshNews.h
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface Author : NSObject
//
//@property(nonatomic,strong) NSString *slug;
//@property(nonatomic,strong) NSString *url;
//@property(nonatomic,assign) int id;
//@property(nonatomic,strong) NSString *nickname;
//@property(nonatomic,strong) NSString *last_name;
//@property(nonatomic,strong) NSString *desc;
//@property(nonatomic,strong) NSString *name;
//@property(nonatomic,strong) NSString *first_name;
//
//@end
//
//@interface Custom_fields : NSObject
//
//@property(nonatomic,strong) NSArray *thumb_c;
//@property(nonatomic,strong) NSURL *thumb_m;
//@property(nonatomic,strong) NSArray *views;
//@property(nonatomic,strong) NSString *viewsCount;
//@end

@interface FreshNews : NSObject

//@property(nonatomic,strong) Author *author;
//@property(nonatomic,strong) Custom_fields *custom_fields;
@property(nonatomic,assign) int id;

@property(nonatomic,strong) NSString *title;

@property(nonatomic,strong) NSString *date;

@property(nonatomic,strong) NSString *viewsCount;

@property(nonatomic,assign) int comment_count;

@property(nonatomic,strong) NSString *url;

@property(nonatomic,strong) NSString *authorName;

@property(nonatomic,strong) NSString *tagsTitle;

@property(nonatomic,strong) NSString *authorAndTagsTitle;

@property(nonatomic,strong) NSString *thumb_c;

@property(nonatomic,strong) NSURL *thumb_m;

@end
