//
//  UITextFieldEx.m
//  CarManager
//
//  Created by 刘献亭 on 15/3/21.
//  Copyright (c) 2015年 David. All rights reserved.
//

#import "UITextViewEx.h"

@implementation UITextViewEx


- (void)setPadding:(BOOL)enable top:(float)top right:(float)right bottom:(float)bottom left:(float)left {
    isEnablePadding = enable;
    paddingTop = top;
    paddingRight = right;
    paddingBottom = bottom;
    paddingLeft = left;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    if (isEnablePadding) {
        return CGRectMake(bounds.origin.x + paddingLeft,
                          bounds.origin.y + paddingTop,
                          bounds.size.width - paddingRight, bounds.size.height - paddingBottom);
    } else {
        return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    }
}

//- (CGRect)caretRectForPosition:(UITextPosition *)position {
//    CGRect originalRect = [super caretRectForPosition:position];
//    originalRect.size.height = 20.0f;
//    return originalRect;
//}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (NSRange) selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void) setSelectedRange:(NSRange) range
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

-(void)dealloc{
    LogBlue(@"textView delloc");
}

@end
