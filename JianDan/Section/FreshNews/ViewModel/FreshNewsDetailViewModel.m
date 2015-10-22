//
//  FreshNewsDetailViewModel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/9.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsDetailViewModel.h"
#import "FreshNews.h"
#import "FreshNewsDetail.h"
#import "NSDate+Additions.h"

@interface FreshNewsDetailViewModel ()

@property(nonatomic, strong) RACCommand *soureCommand;

@end

@implementation FreshNewsDetailViewModel


- (RACCommand *)soureCommand {
    if (!_soureCommand) {
        @weakify(self)
        _soureCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(FreshNews *freshNews) {
            @strongify(self)
            NSString * url = [NSString stringWithFormat:@"%@%d", freshNewDetailUrl, freshNews.id];
            return [[AFNetWorkUtils racGETWithURL:url class:[FreshNewsDetail class]] map:^id(FreshNewsDetail *freshNewsDetail) {
                return [self getHtml:freshNewsDetail.post.content freshNews:freshNews];
            }];
        }];
    }
    return _soureCommand;
}

- (NSString *)getHtml:(NSString *)content freshNews:(FreshNews *)freshNews {
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<!DOCTYPE html>"];
    [html appendString:@"<!DOCTYPE html>"];
    [html appendString:@"<html dir=\"ltr\" lang=\"zh\">"];
    [html appendString:@"<head>"];
    [html appendString:@"<meta name=\"viewport\" content=\"width=100%; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\" />"];
    [html appendString:@"<link  href=\"style.css\" type=\"text/css\"  rel=\"stylesheet\" media=\"screen\" />"];
    [html appendString:@"</head>"];
    [html appendString:@"<body style=\"padding:0px 8px 8px 8px;\">"];
    [html appendString:@"<div id=\"pagewrapper\">"];
    [html appendString:@"<div id=\"mainwrapper\" class=\"clearfix\">"];
    [html appendString:@"<div id=\"maincontent\">"];
    [html appendString:@"<div class=\"post\">"];
    [html appendString:@"<div class=\"posthit\">"];
    [html appendString:@"<div class=\"postinfo\">"];
    [html appendString:@"<h2 class=\"thetitle\">"];
    [html appendString:@"<a>"];
    [html appendString:freshNews.title];
    [html appendString:@"</a>"];
    [html appendString:@"</h2>"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[freshNews.date doubleValue]];
    [html appendFormat:@"%@ @ %@", freshNews.authorName, [date toString]];
    [html appendString:@"</div>"];
    [html appendString:@"<div class=\"entry\">"];
    @try {
        NSRange startRannge = [content rangeOfString:@"<iframe"];
        if (startRannge.length) {
            NSRange endRannge = [content rangeOfString:@"</iframe>"];
            NSMutableString *iFrameString = [[content substringWithRange:NSMakeRange(startRannge.location, endRannge.location - startRannge.location)] mutableCopy];
            NSRange widthStartRange = [iFrameString rangeOfString:@"width:"];
            if (widthStartRange.length) {
                NSRange widthendRange = [iFrameString rangeOfString:@"height"];
                NSString * newIFrame = [iFrameString stringByReplacingCharactersInRange:NSMakeRange(widthStartRange.location, widthendRange.location - widthStartRange.location) withString:@"width:100%;"];
                content = [content stringByReplacingCharactersInRange:NSMakeRange(startRannge.location, endRannge.location - startRannge.location) withString:newIFrame];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    [html appendString:content];
    [html appendString:@"</div>"];
    [html appendString:@"</div>"];
    [html appendString:@"</div>"];
    [html appendString:@"</div>"];
    [html appendString:@"</div>"];
    [html appendString:@"</div>"];
    [html appendString:@"</body>"];
    [html appendString:@"</html>"];
    return html;
}

@end
