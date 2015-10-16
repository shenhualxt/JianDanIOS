//
//  UIWebView+RAC.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/14.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "UIWebView+RAC.h"
#import  <objc/runtime.h>

#define kUIWebViewRACDelegate @"UIWebViewRACDelegate"

@interface UIWebView()

@end

@implementation UIWebView (RAC)


-(void)setRac_delegate:(id<UIWebViewDelegate>)rac_delegate{
    objc_setAssociatedObject(self, kUIWebViewRACDelegate, rac_delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id<UIWebViewDelegate>)rac_delegate{
    return objc_getAssociatedObject(self, kUIWebViewRACDelegate);
}

-(RACSignal *)rac_isLoadingSignal{
    self.delegate=self;
    //_cmd在Objective-C的方法中表示当前方法的selector，正如同self表示当前方法调用的对象实例。== rac_isLoadingSignal
    RACSignal *signal=objc_getAssociatedObject(self, _cmd);
    if (signal!=nil) {
        return signal;
    }
    
    RACSignal *startLoadSignal=[[[self rac_signalForSelector:@selector(webViewDidStartLoad:) fromProtocol:@protocol(UIWebViewDelegate)] doNext:^(id x) {
        if ([self.rac_delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
            [self.rac_delegate webViewDidStartLoad:self];
        }
    }]mapReplace:@YES];
    
    RACSignal *finishLoadSignal=[[[self rac_signalForSelector:@selector(webViewDidFinishLoad:) fromProtocol:@protocol(UIWebViewDelegate)] doNext:^(id x) {
        if ([self.rac_delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
            [self.rac_delegate webViewDidFinishLoad:self];
        }
    }] mapReplace:@NO];
    
    RACSignal *failLoadSignal= [[[self rac_signalForSelector:@selector(webView:didFailLoadWithError:) fromProtocol:@protocol(UIWebViewDelegate)] doNext:^(id x) {
        if ([self.rac_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
            [self.rac_delegate webView:self didFailLoadWithError:x];
        }
    }] mapReplace:@NO];

    signal=[RACSignal merge:@[startLoadSignal,finishLoadSignal,failLoadSignal]];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}


@end
