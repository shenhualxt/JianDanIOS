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
    CGSize authorSze=[picture.comment_author sizeOfSimpleTextWithContrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kAuthorFont];
    _authorFrame=CGRectMake(kLeftMargin, kLeftMargin, authorSze.width, authorSze.height);
    
    //date
    CGSize dateSize=[picture.deltaToNow sizeOfSimpleTextWithContrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont];
    _dateFrame=CGRectMake(CGRectGetMaxX(_authorFrame)+kMiddleMargin, kLeftMargin+(authorSze.height-dateSize.height), dateSize.width, dateSize.height);
    

    _textContentFrame=CGRectMake(kLeftMargin,CGRectGetMaxY(_authorFrame)+kMiddleMargin, 0,0);
    if (picture.text_content.length&&![picture.text_content isEqualToString:@""]) {
        CGSize contentSize=[picture.text_content sizeOfSimpleTextWithContrainedToSize:CGSizeMake(kContentWidth, MAXFLOAT) fromFont:kContentFont];
        _textContentFrame=CGRectMake(kLeftMargin,CGRectGetMaxY(_authorFrame)+kMiddleMargin,kContentWidth,contentSize.height);
    }
    
    //pic
    _pictureFrame=CGRectMake(kLeftMargin, CGRectGetMaxY(_textContentFrame)+kMiddleMargin, 0, 0);
    if (picture.picUrl) {
        _pictureFrame=CGRectMake(2*kLeftMargin, CGRectGetMaxY(_textContentFrame)+2*kMiddleMargin, kContentWidth, _pictureSize.height);
        //gif
        CGFloat gifX=CGRectGetMidX(_pictureFrame)-kGifWidth/2.0;
        CGFloat gifY=CGRectGetMidY(_pictureFrame)-kGifWidth/2.0;
        _gifFrame=CGRectMake(gifX, gifY, kGifWidth, kGifWidth);
    }
    
    //OO
    _OOPoint=CGPointMake(kLeftMargin, CGRectGetMaxY(_pictureFrame)+(kButtonHeight-dateSize.height)/2.0);
    
    //XX
    _XXPoint=CGPointMake(_OOPoint.x+kButtonWidth, _OOPoint.y);
    
    //comment
    _commentPoint=CGPointMake(_XXPoint.x+kButtonWidth, _OOPoint.y);
    
    //share
    CGSize shareSize=[@"•••" sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:kDateFont lineSpace:0];
    _sharePoint=CGPointMake(kContentWidth-shareSize.width, _OOPoint.y);
    
    //cell背景
    _bgViewFrame=CGRectMake(kMiddleMargin, kMiddleMargin, kCellWidth, _OOPoint.y+kButtonHeight);
    
    //cell高度
    _cellHeight=CGRectGetMaxY(_bgViewFrame);
}

-(void)setPictureSize:(CGSize)pictureSize{
    _pictureSize=[PictureFrame scaleSize:pictureSize];
}

+(CGRect)getButtonFrameFromPoint:(CGPoint)point pictureFrame:(CGRect)pictureFrame{
    return CGRectMake(point.x, CGRectGetMaxY(pictureFrame), kButtonWidth, kButtonHeight);
}

+(CGSize)scaleSize:(CGSize)oldSize{
    CGFloat ratio = (kCellWidth)/oldSize.width;
    NSInteger mHeight = oldSize.height * ratio;
    if (mHeight>SCREEN_HEIGHT) {
        mHeight=SCREEN_HEIGHT;
    }
    return CGSizeMake(kCellWidth, mHeight);
}

+(CGSize)scaleSizeWithMaxHeight:(CGSize)oldSize{
    CGFloat ratio = (kCellWidth)/oldSize.width;
    NSInteger mHeight = oldSize.height * ratio;
    return CGSizeMake(kCellWidth, mHeight);
}

MJCodingImplementation

@end
