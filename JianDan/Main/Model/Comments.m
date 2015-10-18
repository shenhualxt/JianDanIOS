//
//  Comments.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "Comments.h"
#import "NSString+Date.h"

@implementation Comments

+(NSDictionary *)objectClassInArray{
    return @{@"parents":[NSString class]};
}

+(NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"post_id" : @"id",
             @"authorName" : @"author.name",
             @"avatar_url" : @"author.avatar_url",
             };
}

-(NSString *)date{
    if (!_date) {
        _date=_created_at;
        _date.dateFormat=@"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    }
    return [_date deltaTimeToNow];
}

-(void)setThread_id:(NSString *)thread_id{
    if (!_thread_id) {
        _thread_id=thread_id;
        if (!_post_id) {
            _post_id=_thread_id;
        }
    }
}

-(void)setCreated_at:(NSString *)created_at{
    if (!_created_at) {
        _created_at=created_at;
        _date=created_at;
        _date.dateFormat=@"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        _date=[_date deltaTimeToNow];
    }
}

-(CGFloat)nameWidth{
    return [_name sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}].width;
}

-(BOOL)isEqual:(Comments *)object{
    return [object.post_id isEqualToString: self.post_id];
}

-(void)setMessage:(NSString *)message{
    if (!_message) {
        _message=message;
        _content=message;
    }
}

-(void)setAuthorName:(NSString *)authorName{
    if (!_authorName) {
        _authorName=authorName;
        _name=authorName;
    }
}


-(NSString *)getPost_id{
    return self.post_id;
}

-(NSInteger)encreaseVote_negative{
    return  ++self.vote_negative;
}

-(NSInteger)encreaseVote_positive{
    return  ++self.vote_positive;
}

@end
