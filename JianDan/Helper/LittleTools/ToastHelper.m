//
//  ToastHelper.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/11.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "ToastHelper.h"
#import "MBProgressHUD.h"
@interface ToastHelper()

@property(nonatomic,strong) MBProgressHUD *HUD;

@end

@implementation ToastHelper

DEFINE_SINGLETON_IMPLEMENTATION(ToastHelper)

/**
 *  再window上显示用户等待框加文字
 *
 *  @param textString 文字
 *  @param timerDelay 时间
 */
-(void)toast:(NSString *)textString delayTime:(int)delayTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows objectAtIndex:1] animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.animationType = MBProgressHUDAnimationZoomOut;
        hud.labelText = textString;
        hud.margin = 10.0f;
        hud.yOffset = 0.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:delayTime];
    });
}

-(void)toast:(NSString *)textString{
    [self toast:textString delayTime:1];
}

-(void)setUp{
    UIView *view=[UIApplication sharedApplication].keyWindow;
    self.HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:self.HUD];
}

-(void)setSimleProgressVisiable:(BOOL)simleProgressVisiable{
    if (simleProgressVisiable) {
        [self.HUD show:YES];
    }else{
        [self.HUD hide:YES];
    }
}



@end
