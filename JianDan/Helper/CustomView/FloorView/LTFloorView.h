//
//  LTFloorView.h
//  LTFloorViewDemo
//
//  Created by 刘献亭 on 15/9/14.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LTFloorView;

@protocol LTFloorViewDataSource <NSObject>

@required

- (NSInteger)numberOfSubFloorsInFloorView:(LTFloorView *)floorView;

-(UIView *)floorView:(LTFloorView *)floorView subFloorViewAtIndex:(NSInteger)index;

@end

@protocol LTFloorViewDelegate <NSObject>

@optional

- (void)floorView:(LTFloorView *)floorView didSelectRowAtIndex:(NSInteger)index;

@end

@interface LTFloorView : UIView

@property (nonatomic, weak) id <LTFloorViewDataSource> dataSource;

@property (nonatomic, weak) id <LTFloorViewDelegate> delegate;


@property(nonatomic,strong) UIColor *bgColor;

@property(nonatomic,strong) UIColor *borderColor;

@end
