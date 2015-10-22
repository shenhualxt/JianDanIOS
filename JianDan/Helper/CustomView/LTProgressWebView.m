//
//  LTUIWebView.m
//  WheelManager
//
//  Created by 刘献亭 on 15/10/14.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "LTProgressWebView.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
@interface LTProgressWebView()

@property(strong,nonatomic) NJKWebViewProgress *progressProxy;

@property (strong,nonatomic) UIProgressView *progressView;

@end

@implementation LTProgressWebView


- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}


-(void)awakeFromNib{
    [self setUp];
}

-(void)setUp{
    self.progressProxy=[NJKWebViewProgress new];
    self.delegate=self.progressProxy;

    __weak __typeof(&*self) weakSelf = self;
    self.progressProxy.progressBlock=^(float progress){
        weakSelf.progressView.progress=progress;
        if (progress>=1) {
            [weakSelf.progressView removeFromSuperview];
        }
    };
}

-(UIProgressView *)progressView{
    if(!_progressView){
        _progressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame=CGRectMake(0, 0, self.frame.size.width, 2);
        _progressView.progress=0;
        [self addSubview:_progressView];
    }
    return _progressView;
}



-(void)setProgressDelegate:(id<UIWebViewDelegate>)progressDelegate{
    self.progressProxy.webViewProxyDelegate=progressDelegate;
}

@end
