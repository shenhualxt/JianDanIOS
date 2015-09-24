//
//  ShareToViewModel.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/13.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareToViewModel : NSObject<UITextViewDelegate>

@property(nonatomic,assign) NSInteger currentCount;

@property(nonatomic, strong) RACSignal *textViewChangedSignal;

@property(nonatomic, strong) RACCommand *textViewChangedCommand;


@end
