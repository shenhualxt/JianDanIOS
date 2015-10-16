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
#define floorNumWH 20
#define maxFloorNum 3

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define kBackgroundColor [UIColor colorWithRed:250.0/255.0 green:249.0/255.0 blue:222/255.0 alpha:1]
#define kBorderColor [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221/255.0 alpha:1].CGColor

@interface LTFloorView()

@property(nonatomic,strong) NSMutableArray *floorNumLayerArray;

@property (nonatomic, assign) BOOL didUpdateFLoorNumLayer;

@property(nonatomic,assign) NSInteger numOfSubFloors;

@end

@implementation LTFloorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints=NO;
        self.userInteractionEnabled=YES;
    }
    return self;
}

-(void)awakeFromNib{
     self.floorNumLayerArray=[NSMutableArray array];
    self.translatesAutoresizingMaskIntoConstraints=NO;
    self.userInteractionEnabled=YES;
}

-(void)setDataSource:(id<LTFloorViewDataSource>)dataSource{
    if (dataSource==nil) {
        return;
    }
    
    _dataSource=dataSource;
    if ([_dataSource respondsToSelector:@selector(numberOfSubFloorsInFloorView:)]) {
        self.numOfSubFloors = [_dataSource numberOfSubFloorsInFloorView:self];
        if (!self.numOfSubFloors) {
            return;
        }
    }
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    [self setBgOnView:self];
    //只有一个评论的时候
    UIView *subFloorView=[_dataSource floorView:self subFloorViewAtIndex:0];
    [self addSubview:subFloorView];
    [subFloorView autoPinEdgesToSuperviewEdges];
    subFloorView.tag=0;
    [self addRegestureOnView:subFloorView];
    
    [self setBgOnView:subFloorView];
    CATextLayer *floorNumLayer=[self createTextLayerWithIndex:0];
    [subFloorView.layer addSublayer:floorNumLayer];
    [self.floorNumLayerArray addObject:floorNumLayer];
    
    //只有一个评论
    if (self.numOfSubFloors==1) {
        return;
    }
    
    //有多个评论
    UIView *previousBackgroundView=subFloorView;
    NSInteger i=1;
    if (self.numOfSubFloors>maxFloorNum) {
        i=self.numOfSubFloors-maxFloorNum;
    }
    for (;i<self.numOfSubFloors; i++) {
        //如果是最后一个
        subFloorView=[_dataSource floorView:self subFloorViewAtIndex:i];
        
        //上一个评论从父view中移除，同时四周的约束也被移除
        [previousBackgroundView removeFromSuperview];
        
        NSInteger floorNubRightMargin=i;
        
        if (self.numOfSubFloors>maxFloorNum) {
            floorNubRightMargin=i-(self.numOfSubFloors-maxFloorNum)+1;
        }
        
        //若果是最后一个，直接添加到FloorView上，不必再创建subFloorBackgroundView
        if (i==self.numOfSubFloors-1) {
            [self addSubview:previousBackgroundView];
            [previousBackgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kEdge, kEdge, kEdge, kEdge) excludingEdge:ALEdgeBottom];
            
            [self addSubview:subFloorView];
            [subFloorView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousBackgroundView];
            [subFloorView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
            subFloorView.tag=i;
            [self addRegestureOnView:subFloorView];
            CATextLayer *floorNumLayer=[self createTextLayerWithIndex:(int)floorNubRightMargin];
            [subFloorView.layer addSublayer:floorNumLayer];
            [self.floorNumLayerArray addObject:floorNumLayer];
            return;
        }
        //添加到下面的大的黄色背景view中,将评论view添加到上一个评论的下方
        UIView *subFloorBackgroundView=[UIView new];
        [self setBgOnView:subFloorBackgroundView];
        
        [subFloorBackgroundView addSubview:previousBackgroundView];
        [previousBackgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kEdge, kEdge, kEdge, kEdge) excludingEdge:ALEdgeBottom];
        
        [subFloorBackgroundView addSubview:subFloorView];
        [subFloorView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousBackgroundView];
        [subFloorView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        
        
        CATextLayer *floorNumLayer=[self createTextLayerWithIndex:(int)floorNubRightMargin];
        [subFloorView.layer addSublayer:floorNumLayer];
        [self.floorNumLayerArray addObject:floorNumLayer];
        
        //将新产生的view,添加到LTFloorView中，添加四周的约束
        [self insertSubview:subFloorBackgroundView atIndex:0];
        [subFloorBackgroundView autoPinEdgesToSuperviewEdges];
        
        previousBackgroundView=subFloorBackgroundView;
        
        subFloorBackgroundView.tag=i;
        [self addRegestureOnView:subFloorBackgroundView];
    }
}



-(void)layoutSubviews{
    [super layoutSubviews];
    //在约束更新完之后调整floorNum的位置
    if (!self.didUpdateFLoorNumLayer&&self.floorNumLayerArray.count) {
        for (int i=0; i<self.floorNumLayerArray.count; i++) {
            CATextLayer *layer=self.floorNumLayerArray[i];
            NSInteger floorNum=self.numOfSubFloors<=maxFloorNum?:maxFloorNum;
            int x=self.frame.size.width-(floorNum-i+1)*kEdge-floorNumWH;
            CGPoint position=layer.position;
            position.x=x;
            layer.position=position;
        }
        self.didUpdateFLoorNumLayer=YES;
    }
}


- (CATextLayer *)createTextLayerWithIndex:(int)index {
    CATextLayer *layer = [CATextLayer new];
    layer.bounds = CGRectMake(0, 0, floorNumWH, floorNumWH);
    layer.string = [NSString stringWithFormat:@"%d",index+1];
    layer.fontSize = 14.0;
    layer.alignmentMode = kCAAlignmentLeft;
    layer.foregroundColor = [UIColor blackColor].CGColor;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    NSInteger floorNum=self.numOfSubFloors<=maxFloorNum?:maxFloorNum;
    int x=self.frame.size.width-(floorNum-index+1)*kEdge-floorNumWH;
    layer.position = CGPointMake(x, floorNumWH/2.0);
    layer.anchorPoint=CGPointMake(0.5, 0);
    return layer;
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

-(void)setBgOnView:(UIView *)view{
    view.backgroundColor =self.bgColor?:kBackgroundColor;
    view.layer.borderColor =self.borderColor.CGColor?:kBorderColor;
    view.layer.borderWidth = 1;
}


@end
