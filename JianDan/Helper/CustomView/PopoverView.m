//
//  PopoverView.m
//  ArrowView
//
//  Created by guojiang on 4/9/14.
//  Copyright (c) 2014年 LINAICAI. All rights reserved.
//

#import "PopoverView.h"


#define kArrowHeight 10.f
#define kArrowCurvature 6.f
#define SPACE 2.f
#define ROW_HEIGHT 44.f
#define TITLE_FONT [UIFont systemFontOfSize:16]
//#define RGB(r, g, b)    [UIColor colorWithRed : (r) / 255.f green : (g) / 255.f blue : (b) / 255.f alpha : 1.f]



@interface PopoverView () <UITableViewDataSource, UITableViewDelegate> {
    CGRect _btnFrame;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIButton *handerView;

@end

@implementation PopoverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = RGB(200, 199, 204);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithBtnFrame:(CGRect)btnFrame titles:(NSArray *)titles images:(NSArray *)images {
    self = [super init];
    if (self) {
        self.titleArray = titles;
        self.imageArray = images;
        _btnFrame = btnFrame;
        self.frame = [self getViewFrame];
        [self addSubview:self.tableView];
    }
    return self;
}

- (id)initWithBtnFrame:(CGRect)btnFrame view:(UIView *)view position:(Position)position {
    self = [super init];
    if (self) {
        _btnFrame = btnFrame;
        self.frame = [self getViewFrameWithPosition:position view:view];
        //        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [self addSubview:view];
    }
    return self;
}

- (CGRect)getViewFrameWithPosition:(Position)position view:(UIView *)view {
    int width = view.frame.size.width;
    int height = view.frame.size.height;
    int x = _btnFrame.origin.x - width;
    int y = _btnFrame.origin.y + _btnFrame.size.height / 2 - height / 2 + 64;
    return CGRectMake(x, y, width, height);
}

- (CGRect)getViewFrame {
    return CGRectMake(_btnFrame.origin.x, _btnFrame.origin.y + _btnFrame.size.height + 1, _btnFrame.size.width, [self.titleArray count] * ROW_HEIGHT);
}

- (void)show {
    _isShowing = YES;
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    //button的底部中间位置
    //    CGPoint point = CGPointMake(_btnFrame.origin.x + _btnFrame.size.width / 2, _btnFrame.origin.y + _btnFrame.size.height);
    ////    将像素point从view中转换到当前视图中，返回在当前视图中的像素值,(button中的一个点，在_handerView中的位置)
    //    CGPoint arrowPoint = [self convertPoint:point fromView:_handerView];
    //
    //    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    //    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations: ^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss {
    _isShowing = NO;
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animate {
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations: ^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion: ^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
}

#pragma mark - UITableView

- (UITableView *)tableView {
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.height -= (SPACE - kArrowHeight);
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    //    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    return _tableView;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.backgroundView = [[UIView alloc] init];
    cell.backgroundView.backgroundColor = RGB(245, 245, 245);
    
    if ([_imageArray count] == [_titleArray count]) {
        cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    [self dismiss:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (void)drawRect:(CGRect)rect {
    [self.borderColor set]; //设置线条颜色
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
    
    //填充颜色
    [RGB(245, 245, 245) setFill];
    [popoverPath fill];
    
    [popoverPath closePath];
    [popoverPath stroke];
}

@end
