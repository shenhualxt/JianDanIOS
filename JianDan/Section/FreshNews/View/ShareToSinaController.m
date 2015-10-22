//
//  ShareToSinaController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/11.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "ShareToSinaController.h"
#import "UMSocial.h"
#import "UITextViewEx.h"
#import "ShareToViewModel.h"

#define kCountLabelHeight 30

#define kMaxLen 140

@interface ShareToSinaController () <UITextViewDelegate>

//显示微博内容的文本框
@property(nonatomic, strong) UITextViewEx *textView;
//显示剩余字数的文本
@property(nonatomic, strong) UILabel *countLabel;

@end

@implementation ShareToSinaController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTextView];
    [self createButtonItem];
    [self createCountLable];
    [self bindingViewModel];
}

- (void)bindingViewModel {
    ShareToViewModel *viewModel = [ShareToViewModel new];
    self.textView.delegate = viewModel;
    viewModel.textViewChangedSignal = [[NSNotificationCenter defaultCenter]
            rac_addObserverForName:UITextViewTextDidChangeNotification object:self.textView];

    [viewModel.textViewChangedCommand execute:self.sendObject];

    //键盘弹出式调整label的位置
    WS(ws);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *notification) {
        [ws adjustCountLabelPosition:notification isShow:YES];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification *notification) {
        [ws adjustCountLabelPosition:nil isShow:NO];
    }];


    @weakify(self)
    RACSignal *countSignal = [[[RACSignal merge:@[self.textView.rac_textSignal, RACObserve(self.textView, text)]
    ] filter:^BOOL(id value) {
        @strongify(self)
        if (![CommonUtils isHansInput:self.textView]) {
            return YES;
        }
        return ![CommonUtils isHasHighlightText:self.textView];
    }] map:^id(NSString *value) {
        NSInteger remainCount = kMaxLen - [CommonUtils convertToInt:value];
        return [NSString stringWithFormat:@"%ld", (long) remainCount];
    }];

    RAC(self.countLabel, text) = countSignal;
    RAC(viewModel, currentCount) = countSignal;
}

- (void)createTextView {
    self.title = @"新浪微博";
    UITextViewEx *textView = [[UITextViewEx alloc] initWithFrame:self.view.frame];
    [self.view addSubview:textView];
    NSString * text = self.sendObject;
    if ([self.sendObject isKindOfClass:[RACTuple class]]) {
        text = [(RACTuple *) self.sendObject second];
    }
    textView.text = text;
    //解决输入汉字时界面的晃动
    textView.layoutManager.allowsNonContiguousLayout = NO;
    textView.font = [UIFont systemFontOfSize:18];
    [textView becomeFirstResponder];
    self.textView = textView;
}

- (void)createButtonItem {
    //添加发送按钮
    UIBarButtonItem *sendItem = [self createButtonItem:@"ic_action_send_now"];
    self.navigationItem.rightBarButtonItem = sendItem;
    //发送分享信息
    @weakify(self)
    [[(UIButton *) sendItem.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        NSString * urlResoures = nil;
        if ([self.sendObject isKindOfClass:[RACTuple class]]) {
            urlResoures = [(RACTuple *) self.sendObject first];
        }
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSina] content:self.textView.text image:nil location:nil urlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:urlResoures] presentedController:self completion:^(UMSocialResponseEntity *response) {
            if (response.responseCode == UMSResponseCodeSuccess) {
                [self BackClick];
            }
            [[ToastHelper sharedToastHelper] toast:response.responseCode == UMSResponseCodeSuccess ? @"分享成功" : @"分享失败"];
        }];
    }];
}

- (void)createCountLable {
    //添加字数label 默认在屏幕的右下角
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kCountLabelHeight, SCREEN_WIDTH - 10, kCountLabelHeight)];
    [self.view addSubview:label];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentRight;
    self.countLabel = label;
}

- (void)adjustCountLabelPosition:(const NSNotification *)notification isShow:(BOOL)isShow {
    NSDictionary * info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:1 animations:^{
        CGRect frame = self.countLabel.frame;
        frame.origin.y = self.view.frame.size.height - kCountLabelHeight;
        if (isShow) {
            frame.origin.y -= kbSize.height;
        }
        self.countLabel.frame = frame;

        CGRect textViewFrame = self.textView.frame;
        textViewFrame.size.height = frame.origin.y;
        self.textView.frame = textViewFrame;
    }];
}
@end
