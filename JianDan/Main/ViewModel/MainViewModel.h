//
//  FreshNewsViewModel.h
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainViewModel : NSObject<UITableViewDelegate>

@property(nonatomic,strong,readonly) RACCommand *sourceCommand;

-(void)loadNextPageData;

@end
