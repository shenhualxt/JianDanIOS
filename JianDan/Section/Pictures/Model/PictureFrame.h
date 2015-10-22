//
//  PictureFrame.h
//  JianDan
//
//  Created by 刘献亭 on 15/10/19.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BoredPictures;

#define kLeftMargin 8

#define kMiddleMargin 8

#define kGifWidth 50

#define kButtonWidth 60

#define kButtonHeight 30

#define kCellWidth (SCREEN_WIDTH-2*kMiddleMargin)

#define kContentWidth (kCellWidth-2*kMiddleMargin)

#define kAuthorFont [UIFont boldSystemFontOfSize:17]

#define kDateFont [UIFont systemFontOfSize:15]

#define kContentFont [UIFont systemFontOfSize:18]

@interface PictureFrame : NSObject

/** 子控件的frame数据 */
@property (nonatomic, assign) CGRect authorFrame;

@property (nonatomic, assign) CGRect dateFrame;

@property (nonatomic, assign) CGRect textContentFrame;

@property (nonatomic, assign) CGSize pictureSize;

@property (nonatomic, assign) CGRect pictureFrame;

@property (nonatomic, assign) CGRect gifFrame;


@property (nonatomic, assign) CGPoint OOPoint;

@property (nonatomic, assign) CGPoint XXPoint;

@property (nonatomic, assign) CGPoint commentPoint;

@property (nonatomic, assign) CGPoint sharePoint;

@property (nonatomic, assign) CGRect bgViewFrame;

/** cell的高度 */
@property (nonatomic, assign) CGFloat cellHeight;

/** 数据源 */
@property (nonatomic, strong) BoredPictures *pictures;

+(CGSize)scaleSize:(CGSize)oldSize;

+(CGSize)scaleSizeWithoutMaxHeight:(CGSize)oldSize;

+(CGRect)getButtonFrameFromPoint:(CGPoint)point pictureFrame:(CGRect)pictureFrame;

@end
