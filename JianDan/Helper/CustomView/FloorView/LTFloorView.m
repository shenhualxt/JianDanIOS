//
//  LTFloorView.m
//  LTFloorViewDemo
//
//  Created by 刘献亭 on 15/9/14.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "LTFloorView.h"
#import "PureLayout.h"

#define kEdge 3

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@implementation LTFloorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init{
    
}
//subFloorView.tag=i;
//UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectRowAtIndex:)];
//[subFloorView addGestureRecognizer:gesture];

-(void)setDataSource:(id<LTFloorViewDataSource>)dataSource{
    _dataSource=dataSource;
    self.height=0;
    if ([_dataSource respondsToSelector:@selector(numberOfSubFloorsInFloorView:)]) {
        self.numOfSubFloors = [_dataSource numberOfSubFloorsInFloorView:self];
    }
    
    self.translatesAutoresizingMaskIntoConstraints=NO;
    self.backgroundColor=[UIColor colorWithRed:250.0/255.0 green:249.0/255.0 blue:222/255.0 alpha:1];
    self.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 1;
    self.userInteractionEnabled=YES;
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    //配置子View
    
    //只有一个评论的时候
     UIView *subFloorView=[_dataSource floorView:self subFloorViewAtIndex:0];
    [self addSubview:subFloorView];
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [subFloorView autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
    }];
    [subFloorView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    subFloorView.tag=0;
    [self addRegestureOnView:subFloorView];
    
    //只有一个评论
    if (self.numOfSubFloors==1) {
        return;
    }

    //有多个评论
    subFloorView.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221/255.0 alpha:1].CGColor;
    subFloorView.layer.borderWidth = 1;
    UIView *previousBackgroundView=subFloorView;
    NSInteger i=1;
    if (self.numOfSubFloors>4) {
        i=self.numOfSubFloors-4;
    }
    for (;i<self.numOfSubFloors; i++) {
        //如果是最后一个
        UIView *subFloorView=[_dataSource floorView:self subFloorViewAtIndex:i];
       
        //上一个评论从父view中移除，同时四周的约束也被移除
        [previousBackgroundView removeFromSuperview];

        //添加到下面的大的黄色背景view中
        //将评论view添加到上一个评论的下方
         NSInteger edge=kEdge*(self.numOfSubFloors-i);
        if (i==self.numOfSubFloors-1) {
            [self addSubview:previousBackgroundView];
            [previousBackgroundView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:edge];
            [previousBackgroundView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:edge];
            [previousBackgroundView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:edge];
            
            [self addSubview:subFloorView];
            [subFloorView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousBackgroundView];
            [subFloorView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            [subFloorView autoPinEdgeToSuperviewEdge:ALEdgeRight];
            [subFloorView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
            subFloorView.tag=i;
            [self addRegestureOnView:subFloorView];
            return;
        }
        
         UIView *subFloorBackgroundView=[self createViewWithIndex:i];
        
        [subFloorBackgroundView addSubview:previousBackgroundView];
        [previousBackgroundView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:edge];
        [previousBackgroundView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:edge];
        [previousBackgroundView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:edge];
        
        [subFloorBackgroundView addSubview:subFloorView];
        [subFloorView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousBackgroundView];
        [subFloorView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [subFloorView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [subFloorView autoPinEdgeToSuperviewEdge:ALEdgeBottom];

   
        //将新产生的view,添加到LTFloorView中，添加四周的约束
        [self insertSubview:subFloorBackgroundView atIndex:0];
        [subFloorBackgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
         previousBackgroundView=subFloorBackgroundView;
        
        subFloorBackgroundView.tag=i;
        [self addRegestureOnView:subFloorBackgroundView];
    }
}

-(void)addRegestureOnView:(UIView *)view{
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectRowAtIndex:)];
    [view addGestureRecognizer:gesture];
}

-(void)didSelectRowAtIndex:(UITapGestureRecognizer *)gesture{
    if ([_delegate respondsToSelector:@selector(floorView:didSelectRowAtIndex:)]) {
        [_delegate floorView:self didSelectRowAtIndex:gesture.view.tag];
    }
}

- (UIView *)createViewWithIndex:(NSInteger)index {
    UIView *view = [UIView new];
    NSInteger x=(self.numOfSubFloors-1-index)*kEdge;
    view.frame = CGRectMake(x,x,self.frame.size.width-2*x,0);
    view.backgroundColor =[UIColor colorWithRed:250.0/255.0 green:249.0/255.0 blue:222/255.0 alpha:1];
    if (self.bgImage) {
        self.layer.contents=(__bridge id)(self.bgImage.CGImage);
        view.backgroundColor=[UIColor clearColor];
    }
    
    view.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221/255.0 alpha:1].CGColor;
    view.layer.borderWidth = 1;
    return view;
}


@end
