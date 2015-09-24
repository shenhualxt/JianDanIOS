//
//  ShareToViewModel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/13.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "ShareToViewModel.h"
#import "UITextViewEx.h"
#define kMaxLen 140

@interface ShareToViewModel()

//在开始输入中文前，保存原先的值
@property(nonatomic, copy) NSString *previousText;
//当前输入的是否是中文（shouldChangeTextInRange中赋值，textViewEditChanged中使用，因为在联想和选择中文时不调用shouldChangeTextInRange方法，只能如此）
@property(nonatomic, assign) BOOL isHans;

@end

@implementation ShareToViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
      [self setUp];
    }
    return self;
}

-(void)setUp{
   self.textViewChangedCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
       self.previousText=input;
       return self.textViewChangedSignal;
   }];
    
    [[self.textViewChangedCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        [self textViewEditChanged:x];
    }];
}

#pragma mark -UITextView delegate
- (BOOL)textView:(UITextViewEx *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //允许在任何时候，删除按钮可用
    if (!text.length) {
        return YES;
    }
    //点击键盘的
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    //允许删除键，在大于kMaxLen后不再继续输入
    int currentTextCount = kMaxLen - self.currentCount;
    if (currentTextCount >= kMaxLen) {
        return NO;
    }
    //通过键盘中文数据
    if ([CommonUtils isHansInput:textView] && ([CommonUtils isHasHighlightText:textView] || [CommonUtils isSpecialHansChar:text])) {
        self.isHans = YES;
        return YES;
    } else {
        self.isHans = NO;
    }
    //中间插入字符 英文,拷贝
    BOOL isInsert = range.location != textView.text.length;
    if (isInsert) {
        return [self insertText:textView range:&range text:text previousText:textView.text];
    }
    return YES;
}



- (BOOL)insertText:(UITextViewEx *)textView range:(NSRange *)range text:(NSString *)text previousText:(NSString *)previousText{
    if (!text||!text.length) {
        return YES;
    }
    //1,能全部插入
    NSInteger currentTextCount = kMaxLen - self.currentCount;
    NSInteger newTextCount = [CommonUtils convertToInt:text];
    if ((currentTextCount + newTextCount) < kMaxLen) {
        return YES;
    }
    
    text=[self cutText:text maxLength:self.currentCount];
    textView.text = [previousText stringByReplacingCharactersInRange:*range withString:text];
    [textView setSelectedRange:NSMakeRange((*range).location + text.length, 0)];
    return NO;
}

#pragma mark - Notification Method
- (void)textViewEditChanged:(NSNotification *)notification {
    UITextViewEx *textView=(UITextViewEx *)notification.object;
    NSString *toBeString = textView.text;
    //中间插入 通过键盘输入汉字 联想
    NSRange range = textView.selectedRange;
    BOOL isInsert = range.location != textView.text.length;
    if ([CommonUtils isHansInput:textView] && isInsert&&([CommonUtils isHasHighlightText:textView] || self.isHans)) {// 简体中文输入
        //新插入文字内容的长度
        NSInteger offset = textView.text.length - self.previousText.length;
        if (offset<=0) {
            return;
        }
        //结束时 第一个为汉字
        NSRange newRange = NSMakeRange(range.location - offset, offset);
        if ((newRange.location+newRange.length)<textView.text.length) {
            NSString *newText = [textView.text substringWithRange:newRange];
            if ([CommonUtils isChinese:newText]) {
                newRange.length=0;
                [self insertText: textView range:&newRange text:newText previousText:self.previousText];
            }
        }
        return;
    }
    self.previousText = textView.text;
    
    //裁剪多余的文字
    int currentTextCount = kMaxLen - self.currentCount;
    if (currentTextCount > kMaxLen) {
        textView.text = [self cutText:toBeString maxLength:kMaxLen];
    }
}

- (NSString *)cutText:(NSString *)text maxLength:(NSInteger)maxLength{
    if (!text||[text isEqualToString:@""]) {
        return nil;
    }
    //2,不能全部插入
    while ([CommonUtils convertToInt:text] > maxLength) {
        text = [text substringToIndex:text.length - 1];
    }
    //最后一个是半个的情况
    NSString *last = [text substringToIndex:text.length - 1];
    BOOL lastIsHalf = [CommonUtils convertToInt:last] == maxLength;
    if (lastIsHalf) {
        text = last;
    }
    return text;
}


@end
