//
//  ToastHelper.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/11.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "ToastHelper.h"
#import "MBProgressHUD.h"
#import "NSString+Additions.h"
@interface ToastHelper()<MBProgressHUDDelegate>

@property(nonatomic,strong) UIView *hudParentView;

@property(nonatomic,strong) UIView *toastHUDParentView;

@property(nonatomic,strong) MBProgressHUD *HUD;

@end

@implementation ToastHelper

DEFINE_SINGLETON_IMPLEMENTATION(ToastHelper)

-(void)setUp{
   

}

-(void)setSimleProgressVisiable:(BOOL)simleProgressVisiable{
     dispatch_async(dispatch_get_main_queue(), ^{
        if (simleProgressVisiable) {
            UIView *view=[UIApplication sharedApplication].keyWindow;
            if (!view) {
                return;
            }
            self.hudParentView=[UIView new];
            self.hudParentView.bounds=CGRectMake(0, 0, 150, 80);
            self.hudParentView.center=CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
            [view addSubview:self.hudParentView];
            self.HUD = [[MBProgressHUD alloc] initWithView:self.hudParentView];
            [self.hudParentView addSubview:_HUD];
            _HUD.delegate=self;
            _HUD.removeFromSuperViewOnHide = YES;
            [_HUD show:YES];
        }else{
            [_HUD hide:YES];
        }
     });
}

- (void)hudWasHidden:(MBProgressHUD *)hud{
    if (self.hudParentView&&self.HUD==hud) {
        [self.HUD removeFromSuperview];
        [self.hudParentView removeFromSuperview];
        self.HUD=nil;
        self.hudParentView=nil;
         return;
    }
    if (self.toastHUDParentView) {
        [self.toastHUDParentView removeFromSuperview];
        self.toastHUDParentView=nil;
    }
}

/**
 *  再window上显示用户等待框加文字
 *
 *  @param textString 文字
#0	0x000a2298 in -[ToastHelper setUp] at /Users/shenhualxt/JianDanIOS/JianDan/Helper/LittleTools/ToastHelper.m:51
 *  @param timerDelay 时间
 */
-(void)toast:(NSString *)textString delayTime:(int)delayTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view=[UIApplication sharedApplication].keyWindow;
        if([UIApplication sharedApplication].windows.count>1){
            view=[[UIApplication sharedApplication].windows objectAtIndex:1];
        }
        self.toastHUDParentView=[UIView new];
        CGSize textSize=[textString sizeOfSimpleTextWithContrainedToSize:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX) fromFont:[UIFont systemFontOfSize:20]];
        self.toastHUDParentView.bounds=CGRectMake(0, 0, textSize.width*2, 80);
        self.toastHUDParentView.center=CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        [view addSubview:self.toastHUDParentView];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.toastHUDParentView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.animationType = MBProgressHUDAnimationZoomOut;
        hud.labelText = textString;
        hud.margin = 10.0f;
        hud.yOffset = 0.0f;
        hud.delegate=self;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:delayTime];
    });
}

-(void)toast:(NSString *)textString{
    [self toast:textString delayTime:1];
}







@end
