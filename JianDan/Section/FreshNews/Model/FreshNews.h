//
//  FreshNews.h
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FreshNews : NSObject

@property(nonatomic, assign) int id;

@property(nonatomic, strong) NSString *title;

@property(nonatomic, strong) NSString *date;

@property(nonatomic, strong) NSString *viewsCount;

@property(nonatomic, assign) int comment_count;

@property(nonatomic, strong) NSString *url;

@property(nonatomic, strong) NSString *authorName;

@property(nonatomic, strong) NSString *tagsTitle;

@property(nonatomic, strong) NSString *authorAndTagsTitle;

@property(nonatomic, strong) NSString *thumb_c;

@property(nonatomic, strong) NSURL *thumb_m;

@end
