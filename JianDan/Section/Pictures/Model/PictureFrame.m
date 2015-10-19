//
//  PictureFrame.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/19.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "PictureFrame.h"
#import "NSString+Additions.h"
#import "NSString+Date.h"
#import "BoredPictures.h"


@implementation PictureFrame



-(void)setPictures:(BoredPictures *)picture{
    //Author
    CGSize authorSze=[picture.comment_author sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kAuthorFont lineSpace:0];
    _authorFrame=CGRectMake(kLeftMargin, kLeftMargin, authorSze.width, authorSze.height);
    
    //date
    CGSize dateSize=[picture.deltaToNow sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _dateFrame=CGRectMake(CGRectGetMaxX(_authorFrame)+kMiddleMargin, kLeftMargin+(authorSze.height-dateSize.height), dateSize.width, dateSize.height);
    
    //text_content
    CGSize contentSize=[picture.text_content sizeWithConstrainedToSize:CGSizeMake(kWidth, CGFLOAT_MAX) fromFont:kDateFont lineSpace:5];
    _textContentFrame=CGRectMake(kLeftMargin,CGRectGetMaxY(_authorFrame)+kMiddleMargin,kWidth-2*kLeftMargin,contentSize.height);
    
    //pic
    _pictureFrame=CGRectMake(kLeftMargin, CGRectGetMaxY(_textContentFrame)+kMiddleMargin, kWidth-2*kLeftMargin, picture.picSize.height);
    
    //gif
    CGFloat gifX=CGRectGetMidX(_pictureFrame)-kGifWidth/2.0;
    CGFloat gifY=CGRectGetMidY(_pictureFrame)-kGifWidth/2.0;
    _gifFrame=CGRectMake(gifX, gifY, kGifWidth, kGifWidth);
    
    //OO
    NSString *OOText=[NSString stringWithKey:"OO " value:(int)picture.vote_positive];
    CGSize OOSize=[OOText sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _OOFrame=CGRectMake(kLeftMargin, CGRectGetMaxY(_pictureFrame)+kMiddleMargin, OOSize.width, OOSize.height);
    
    //XX
    NSString *XXText=[NSString stringWithKey:"OO " value:(int)picture.vote_negative];
    CGSize XXSize=[XXText sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _XXFrame=CGRectMake(CGRectGetMaxX(_OOFrame)+kMiddleMargin, _OOFrame.origin.y, XXSize.width, XXSize.height);
    
    //comment
    NSString *commentText=[NSString stringWithKey:"吐槽 " value:(int)picture.vote_negative];
    CGSize commentSize=[commentText sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _commentFrame=CGRectMake(CGRectGetMaxX(_XXFrame)+kMiddleMargin, _OOFrame.origin.y, commentSize.width, commentSize.height);
    
    //share
    NSString *shareText=@"•••";
    CGSize shareSize=[shareText sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _shareFrame=CGRectMake(CGRectGetMaxX(_pictureFrame)-shareSize.width, _OOFrame.origin.y, shareSize.width, shareSize.height);
    
    _bgViewFrame=CGRectMake(0, 0, kWidth, CGRectGetMaxY(_OOFrame)+kMiddleMargin);
    
    _cellHeight=CGRectGetMaxY(_bgViewFrame);
}

MJCodingImplementation

@end
