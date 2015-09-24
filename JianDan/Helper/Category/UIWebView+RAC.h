//
//  UIWebView+RAC.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/14.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIWebViewRACDelegate <NSObject>

@optional
- (void)rac_webViewDidStartLoad:(UIWebView *)webView;
- (void)rac_webViewDidFinishLoad:(UIWebView *)webView;
- (void)rac_webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface UIWebView (RAC)

-(void)setRACDelegate:(id<UIWebViewRACDelegate>)delegate;

-(RACSignal *)rac_isLoadingSignal;

@end
