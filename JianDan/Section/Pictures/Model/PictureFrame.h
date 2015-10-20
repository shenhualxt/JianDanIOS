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

#define kWidth SCREEN_WIDTH

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

@property (nonatomic, assign) CGRect OOFrame;

@property (nonatomic, assign) CGRect XXFrame;

@property (nonatomic, assign) CGRect commentFrame;

@property (nonatomic, assign) CGRect shareFrame;

@property (nonatomic, assign) CGRect bgViewFrame;

/** cell的高度 */
@property (nonatomic, assign) CGFloat cellHeight;

/** 数据源 */
@property (nonatomic, strong) BoredPictures *pictures;

+(CGSize)scaleSize:(CGSize)oldSize;

@end
