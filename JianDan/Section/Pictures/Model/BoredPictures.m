//
//  BoredPictures.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/19.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "BoredPictures.h"
#import "NSDate+MJ.h"
#import "NSString+Date.h"
#import "FastImage.h"

@interface BoredPictures()

@end

@implementation Video

-(void)setBigPicUrl:(NSString *)bigPicUrl{
    if (bigPicUrl) {
        _thumbnail=bigPicUrl;
    }
}

-(void)setBimg:(NSString *)bimg{
    if (bimg) {
        _thumbnail=bimg;
    }
}

MJCodingImplementation

@end

@implementation BoredPictures{
    NSString *_comment_count;
}

-(NSString *)getPost_id{
    return self.post_id;
}

-(NSInteger)encreaseVote_negative{
    return  ++self.vote_negative;
}

-(NSInteger)encreaseVote_positive{
    return  ++self.vote_positive;
}

-(NSString *)idStr{
    return self.post_id;
}


+(NSDictionary *)objectClassInArray{
    return @{@"pics":[NSString class], @"videos":[Video class]};
}

+(NSDictionary *)replacedKeyFromPropertyName{
    return @{@"post_id" : @"comment_ID"};
}

-(void)setPics:(NSArray *)pics{
    if (pics.count) {
        _picUrl=pics[0];
        if ([_picUrl hasSuffix:@".gif"]) {
             _thumnailGiFUrl=[BoredPictures thumbGIFURLFromURL:[_picUrl copy]];
        }
    }
}

+(NSString *)thumbGIFURLFromURL:(NSString *)imageURL{
    imageURL=[imageURL stringByReplacingOccurrencesOfString:@"mw600" withString:@"small"];
    imageURL=[imageURL stringByReplacingOccurrencesOfString:@"mw1200" withString:@"small"];
    return [imageURL stringByReplacingOccurrencesOfString:@"large" withString:@"small"];
}

-(void)setComment_date:(NSString *)comment_date{
    if (!_comment_date) {
        _comment_date=comment_date;
        
        NSDate* date = [_comment_date dateFromString];
        _date=[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
        
        _deltaToNow=[_comment_date deltaTimeToNow];
    }
}

-(void)setComment_count:(NSString *)comment_count{
    if (!_comment_count) {
        appendCString(&_comment_count, "吐槽 ",(long)[comment_count integerValue]);
    }
}

-(void)setText_content:(NSString *)text_content{
    if (!_text_content) {
        _text_content=[text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    }
}

-(void)setPicSize:(CGSize)picSize{
    CGFloat ratio = (SCREEN_WIDTH-16)/picSize.width;
    NSInteger mHeight = picSize.height * ratio;
    _picSize=CGSizeMake((SCREEN_WIDTH-16), mHeight);
}

MJCodingImplementation
@end


