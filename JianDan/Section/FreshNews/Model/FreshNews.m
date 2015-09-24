//
//  FreshNews.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNews.h"

static NSDateFormatter *formatter;

@implementation FreshNews

+(NSDateFormatter *)formatter{
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    return formatter;
}

- (NSString *)date {
//  "2015-08-30 12:40:26"  ---> NSDate --> 1363948516
  NSDate* date = [[FreshNews formatter] dateFromString:_date];
  return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
}

MJCodingImplementation
@end

@implementation Author

+ (NSDictionary*)replacedKeyFromPropertyName
{
  return @{ @"desc" : @"description" };
}
MJCodingImplementation
@end

@implementation Custom_fields

+(NSDictionary *)objectClassInArray{
  return @{@"views":[NSString class],@"thumb_c":[NSMutableString class]};
}


-(NSURL *)thumb_m{
  if (!_thumb_m) {
    if ([self.thumb_c count]) {
      NSMutableString *thumbImageUrl=self.thumb_c[0];
      _thumb_m=[NSURL URLWithString:[thumbImageUrl stringByReplacingOccurrencesOfString:@"custom" withString:@"medium"]];
    }else{
      return nil;
    }
  }
  return _thumb_m;
}


-(NSString *)viewsCount{
  if (!_viewsCount) {
    if ([self.views count]) {
      _viewsCount=[NSString stringWithFormat:@"浏览%@次",self.views[0]];
    }else{
      _viewsCount=@"浏览0次";
    }
  }
  return _viewsCount;
}
MJCodingImplementation
@end




