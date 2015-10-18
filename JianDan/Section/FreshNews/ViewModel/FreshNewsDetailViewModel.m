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
@interface FreshNewsDetailViewModel()

@property(nonatomic,assign) NSInteger index;

@property(nonatomic,strong) RACCommand *soureCommand;

@property(nonatomic,strong) NSArray *freshNewsArray;

@end

@implementation FreshNewsDetailViewModel


-(RACCommand *)soureCommand{
    if (!_soureCommand) {
        @weakify(self)
        _soureCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
            self.freshNewsArray=turple.first;
            self.index=[turple.second integerValue];
            @strongify(self)
            FreshNews *freshNews=self.freshNewsArray[self.index];
            NSString *url=[NSString stringWithFormat:@"%@%d",freshNewDetailUrl,freshNews.id];
            return [[AFNetWorkUtils racGETWithURL:url class:[FreshNewsDetail class]] map:^id(FreshNewsDetail *freshNewsDetail) {
                return [self getHtml:freshNewsDetail.post.content];
            }];
        }];
    }
    return _soureCommand;
}

-(NSString *)getHtml:(NSString *)content{
    NSMutableString *html=[NSMutableString string];
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
    FreshNews *freshNews=self.freshNewsArray[self.index];
    [html appendString:freshNews.title];
    [html appendString:@"</a>"];
    [html appendString:@"</h2>"];
    [html appendFormat:@"%@ @ %@",freshNews.authorName,freshNews.date];
    [html appendString:@"</div>"];
    [html appendString:@"<div class=\"entry\">"];
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
