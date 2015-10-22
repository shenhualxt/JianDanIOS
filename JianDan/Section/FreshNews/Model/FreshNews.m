//
//  FreshNews.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNews.h"
#import "NSString+Date.h"

static NSDateFormatter *formatter;

@implementation FreshNews

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"viewsCount" : @"custom_fields.views[0]",
            @"authorName" : @"author.name",
            @"tagsTitle" : @"tags[0].title",
            @"thumb_c" : @"custom_fields.thumb_c[0]"
    };
}

- (void)setThumb_c:(NSString *)thumb_c {
    if (!_thumb_c) {
        _thumb_c = thumb_c;
        _thumb_m = [NSURL URLWithString:[thumb_c stringByReplacingOccurrencesOfString:@"custom" withString:@"medium"]];
    }
}

- (void)setDate:(NSString *)date {
    NSDate *newDate = [date dateFromString]; //  "2015-08-30 12:40:26"  ---> NSDate --> 1363948516
    _date = [NSString stringWithFormat:@"%ld", (long) [newDate timeIntervalSince1970]];
}

- (void)setAuthorName:(NSString *)authorName {
    if (!_authorName) {
        _authorName = authorName;
        if (_tagsTitle) {
            _authorAndTagsTitle = [NSString stringWithFormat:@"%@ @ %@", _authorName, _tagsTitle];
        }
    }
}

- (void)setTagsTitle:(NSString *)tagsTitle {
    if (!_tagsTitle) {
        _tagsTitle = tagsTitle;
        if (_authorName) {
            _authorAndTagsTitle = [NSString stringWithFormat:@"%@ @ %@", _authorName, _tagsTitle];
        }
    }
}

- (BOOL)isEqual:(FreshNews *)object {
    return _id == object.id;
}

MJCodingImplementation

@end





