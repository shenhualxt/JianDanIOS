//
//  RWTableViewBindingHelper.h
//  RWTwitterSearch
//
//  Created by Colin Eberhardt on 24/04/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol DynamicHeightModel <NSObject>

- (NSString *)idStr;

- (BOOL)isLoadedImage;

@end

@interface CETableViewBindingHelper : NSObject

@property(assign, nonatomic) BOOL isDynamicHeight;

@property(strong, nonatomic, readonly) NSArray *data;

@property(weak, nonatomic) id <UITableViewDelegate> delegate;

@property(weak, nonatomic) id <UIScrollViewDelegate> scrollViewDelegate;


+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)source
                         selectionCommand:(RACCommand *)selection
                          customCellClass:(Class)clazz;

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)source
                         selectionCommand:(RACCommand *)selection
                        templateCellClass:(Class)clazz;
@end
