//
//  BoredPictures.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/19.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vote.h"
@class PictureFrame;

@interface Video : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *thumbnail;

@property (nonatomic, copy) NSString *bigPicUrl;

@property (nonatomic, copy) NSString *bimg;

@end


@interface BoredPictures : NSObject

@property (nonatomic, assign) NSInteger vote_positive;

@property (nonatomic, strong) NSString *post_id;

@property (nonatomic, assign) NSInteger vote_negative;
//原始日期
@property (nonatomic, copy) NSString *comment_date;

@property (nonatomic, strong) NSString *comment_author;

@property (nonatomic, copy) NSString *text_content;

//视频缩略图
@property (nonatomic, strong) NSArray *pics;
//小视频
@property (nonatomic, strong) NSArray *videos;


@property (nonatomic, assign) BOOL hadLoadImage;
#pragma mar -新添加
//图片地址
@property (nonatomic, strong) NSString *picUrl;

@property (nonatomic, strong) NSString *thumnailGiFUrl;

//评论数量
@property (nonatomic, strong) NSString *comment_count;

//用来排序的日期
@property (nonatomic, strong) NSString *date;

//离现在时间差
@property (nonatomic, strong) NSString *deltaToNow;
//图片大小
@property (nonatomic, assign) CGSize picSize;

@property (nonatomic, strong) PictureFrame *picFrame;

@property (weak, nonatomic) UIImage *image;

@end

