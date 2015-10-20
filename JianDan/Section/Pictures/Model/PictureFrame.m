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
    

    _textContentFrame=CGRectMake(kLeftMargin,CGRectGetMaxY(_authorFrame)+kMiddleMargin, 0,0);
    if (picture.text_content.length&&![picture.text_content isEqualToString:@""]) {
        CGSize contentSize=[picture.text_content sizeOfSimpleTextWithContrainedToSize:CGSizeMake(kWidth-2*kLeftMargin, MAXFLOAT) fromFont:kContentFont];
        _textContentFrame=CGRectMake(kLeftMargin,CGRectGetMaxY(_authorFrame)+kMiddleMargin,kWidth-2*kLeftMargin,contentSize.height);
    }
    
    //pic
    _pictureFrame=CGRectMake(kLeftMargin, CGRectGetMaxY(_textContentFrame)+kMiddleMargin, 0, 0);
    if (picture.picUrl) {
        _pictureFrame=CGRectMake(kLeftMargin, CGRectGetMaxY(_textContentFrame)+kMiddleMargin, kWidth-2*kLeftMargin, _pictureSize.height);
        //gif
        CGFloat gifX=CGRectGetMidX(_pictureFrame)-kGifWidth/2.0;
        CGFloat gifY=CGRectGetMidY(_pictureFrame)-kGifWidth/2.0;
        _gifFrame=CGRectMake(gifX, gifY, kGifWidth, kGifWidth);
    }
    
    //OO
    CGSize OOSize=[picture.vote_negativeStr sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _OOFrame=CGRectMake(kLeftMargin, CGRectGetMaxY(_pictureFrame)+kMiddleMargin, OOSize.width+kLeftMargin, OOSize.height);
    
    //XX
    CGSize XXSize=[picture.vote_positiveStr sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _XXFrame=CGRectMake(CGRectGetMaxX(_OOFrame)+kMiddleMargin, _OOFrame.origin.y, XXSize.width+kLeftMargin, XXSize.height);
    
    //comment
    CGSize commentSize=[picture.comment_count sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _commentFrame=CGRectMake(CGRectGetMaxX(_XXFrame)+kMiddleMargin, _OOFrame.origin.y, commentSize.width+kLeftMargin, commentSize.height);
    
    //share
    CGSize shareSize=[@"•••" sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _shareFrame=CGRectMake(kWidth-kMiddleMargin-shareSize.width, _OOFrame.origin.y, shareSize.width, shareSize.height);
    
    _bgViewFrame=CGRectMake(0, 0, kWidth, CGRectGetMaxY(_OOFrame)+kMiddleMargin);
    
    _cellHeight=CGRectGetMaxY(_bgViewFrame);
}

-(void)setPictureSize:(CGSize)pictureSize{
    _pictureSize=[PictureFrame scaleSize:pictureSize];
}

+(CGSize)scaleSize:(CGSize)oldSize{
    CGFloat ratio = (kWidth-2*kLeftMargin)/oldSize.width;
    NSInteger mHeight = oldSize.height * ratio;
    if (mHeight>SCREEN_HEIGHT) {
        mHeight=SCREEN_HEIGHT;
    }
    return CGSizeMake(kWidth-2*kLeftMargin, mHeight);
}

MJCodingImplementation

@end
