//
//  Urls.h
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#ifndef Urls_h
#define Urls_h

//新鲜事
static NSString* const freshNewUrl = @"http://jandan.net/?oxwlxojflwblxbsapi=get_recent_posts&include=url,date,tags,author,title,comment_count,custom_fields&custom_fields=thumb_c,views&dev=1&page=";

//无聊图
static NSString* const BoredPicturesUrl = @"http://jandan.net/?oxwlxojflwblxbsapi=jandan.get_pic_comments&page=";

//新鲜事详情
static NSString* const freshNewDetailUrl = @"http://i.jandan.net/?oxwlxojflwblxbsapi=get_post&include=content&id=";

//新鲜事评论
static NSString* const freshNewCommentlUrl = @"http://jandan.net/?oxwlxojflwblxbsapi=get_post&include=comments&id=";

//发表评论接口
static NSString* const pushCommentlUrl = @"http://jandan.net/?oxwlxojflwblxbsapi=respond.submit_comment";

#endif /* Urls_h */
