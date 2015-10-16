//
//  VoteViewModel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "VoteViewModel.h"
#import "Vote.h"
#import "NSString+Date.h"

@implementation VoteViewModel

+(void)setVoteButtonOO:(UIButton *)buttonOO buttonXX:(UIButton *)buttonXX cell:(UITableViewCell *)cell vote:(Vote *)vote{
    [buttonOO setTitle:[NSString stringWithKey:"OO " value:(int)vote.vote_positive] forState:UIControlStateNormal];
    [buttonXX setTitle:[NSString stringWithKey:"XX " value:(int)vote.vote_negative] forState:UIControlStateNormal];
    WS(ws)
    [[[buttonOO rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [ws voteWithOption:OO vote:vote button:x];
    }];
    [[[buttonXX rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [ws voteWithOption:XX vote:vote button:x];
    }];
}

+(void)voteWithOption:(VoteOption)option vote:(Vote *)vote button:(UIButton *)button{
    @weakify(self)
    [[self voteWithOption:option commentId:vote.post_id] subscribeNext:^(NSString *resultCode) {
        @strongify(self)
        if ([resultCode isEqualToString:result_oo_success]) {
            //投赞成票成功
            vote.vote_positive++;
            [self setButtonText:button text:vote.vote_positive color:UIColorFromRGB(0xff4444)];
        }else if([resultCode isEqualToString:result_xx_success]){
            //投反对票成功
            NSInteger num=vote.vote_negative++;
            [self setButtonText:button text:num color:UIColorFromRGB(0x99cc00)];
        }else if(![resultCode isEqualToString:result_have_voted]){
            [[ToastHelper sharedToastHelper] toast:@"vote接口调试中"];
        }
    } error:^(NSError *error) {
        [[ToastHelper sharedToastHelper] toast:@"vote接口调试中"];
    }];
}

+(void)setButtonText:(UIButton *)button text:(NSInteger)count color:(UIColor *)color{
    [button setTitle:[NSString stringWithFormat:@"OO %ld",(long)count] forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font=[UIFont boldSystemFontOfSize:14.0];
}

+(RACSignal *)voteWithOption:(VoteOption)option commentId:(NSString *)commentId{
    NSString *url=[NSString stringWithFormat:commentVoteUrl,@(option),commentId];
    return [[AFNetWorkUtils get2racUNJSONWthURL:url] map:^id(id value) {
        //2941297|THANK YOU  |1
        NSString *result = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        NSArray *splitStrings=[result componentsSeparatedByString:@"|"];
        if (splitStrings.count<3){
            [[ToastHelper sharedToastHelper] toast:unExpectedResult];
            return nil;
        }
        NSString *resultCode=splitStrings[2];
        NSString *tipMessage=splitStrings[1];
        [[ToastHelper sharedToastHelper] toast:tipMessage];
        return resultCode;
    }];
}

@end
