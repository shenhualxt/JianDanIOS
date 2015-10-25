//
//  RWTableViewBindingHelper.m
//  RWTwitterSearch
//
//  Created by Colin Eberhardt on 24/04/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import "CETableViewBindingHelper.h"
#import "CEReactiveView.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import "UITableView+FDTemplateLayoutCell.h"

@interface CETableViewBindingHelper () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, readwrite, assign) struct scrollViewDelegateMethodsCaching {

    uint scrollViewDidScroll:1;
    uint scrollViewDidEndDecelerating:1;

} scrollViewDelegateRespondsTo;

@end

@implementation CETableViewBindingHelper {
    NSArray *_data;
    UITableViewCell *_templateCell;
    RACCommand *_selection;
    NSString *_reuseIdentifier;
    UITableView *_tableView;
    NSMutableArray *needLoadArr;
    BOOL scrollToToping;
}

- (void)setScrollViewDelegate:(id <UIScrollViewDelegate>)scrollViewDelegate {
    if (self.scrollViewDelegate != scrollViewDelegate)
        _scrollViewDelegate = scrollViewDelegate;

    struct scrollViewDelegateMethodsCaching newMethodCaching;
    newMethodCaching.scrollViewDidScroll = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)];
    newMethodCaching.scrollViewDidEndDecelerating=[_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
    self.scrollViewDelegateRespondsTo = newMethodCaching;
}

#pragma  mark - initialization

- (instancetype)initWithTableView:(UITableView *)tableView sourceSignal:(RACSignal *)source selectionCommand:(RACCommand *)selection {
    if (self = [super init]) {
        _tableView = tableView;
        _selection = selection;

        [source subscribeNext:^(id x) {
            _data = x;
            [_tableView reloadData];
        }];

        needLoadArr = [[NSMutableArray alloc] init];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView sourceSignal:(RACSignal *)source selectionCommand:(RACCommand *)selection customCellClass:(Class)clazz {
    if (!clazz) {
        return nil;
    }
    self = [self initWithTableView:tableView sourceSignal:source selectionCommand:selection];
    if (self) {
        _reuseIdentifier = NSStringFromClass(clazz);
        UINib *nib = [UINib nibWithNibName:_reuseIdentifier bundle:nil];
        _templateCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
        [_tableView registerNib:nib forCellReuseIdentifier:_reuseIdentifier];
        _tableView.rowHeight = _templateCell.bounds.size.height;
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView sourceSignal:(RACSignal *)source selectionCommand:(RACCommand *)selection templateCellClass:(Class)clazz {
    self = [self initWithTableView:tableView sourceSignal:source selectionCommand:selection];
    if (self) {
        _reuseIdentifier = NSStringFromClass(clazz);
        _templateCell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseIdentifier];
        [_tableView registerClass:clazz forCellReuseIdentifier:_reuseIdentifier];
        _tableView.rowHeight = _templateCell.bounds.size.height; // use the template cell to set the row height
    }
    return self;
}

- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    CGFloat heightForRowAtIndexPath = tableView.rowHeight;
    if (_isDynamicHeight) {
        if (IOS8) {
            heightForRowAtIndexPath = UITableViewAutomaticDimension;
        } else {
            id <DynamicHeightModel> model = _data[indexPath.row];
            heightForRowAtIndexPath = [_tableView fd_heightForCellWithIdentifier:_reuseIdentifier cacheByKey:[model idStr] configuration:^(id <CEReactiveView> cell) {
                [cell bindViewModel:model forIndexPath:indexPath];
            }];
        }
    }
    return heightForRowAtIndexPath;
}

//- (void)configureCell:(id <CEReactiveView>)cell forIndexPath:(NSIndexPath *)indexPath {
//    if ([cell respondsToSelector:@selector(clear)]) {
//        [cell clear];
//    }
//    if (needLoadArr.count > 0 && [needLoadArr indexOfObject:indexPath] == NSNotFound) {
//        if ([cell respondsToSelector:@selector(clear)]) {
//            [cell clear];
//        }
//        return;
//    }
//    if (scrollToToping) {
//        return;
//    }
    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <CEReactiveView> cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(clear)]) {
                [cell clear];
    }
    [cell bindViewModel:_data[indexPath.row] forIndexPath:indexPath];
    return (UITableViewCell *) cell;
}


+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)source
                         selectionCommand:(RACCommand *)selection
                          customCellClass:(Class)clazz {

    return [[CETableViewBindingHelper alloc] initWithTableView:tableView
                                                  sourceSignal:source
                                              selectionCommand:selection
                                               customCellClass:clazz];
}

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)source
                         selectionCommand:(RACCommand *)selection
                        templateCellClass:(Class)clazz {

    return [[CETableViewBindingHelper alloc] initWithTableView:tableView
                                                  sourceSignal:source
                                              selectionCommand:selection
                                             templateCellClass:clazz];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_selection) {
        return;
    }
    // execute the command
    RACTuple *turple = [RACTuple tupleWithObjects:_data[indexPath.row], indexPath, nil];
    [_selection execute:turple];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewDelegateRespondsTo.scrollViewDidScroll == 1) {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [needLoadArr removeAllObjects];
    [[SDWebImageDownloader sharedDownloader] setMaxConcurrentDownloads:3];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [[SDWebImageDownloader sharedDownloader] setMaxConcurrentDownloads:6];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollViewDelegateRespondsTo.scrollViewDidEndDecelerating == 1) {
        [self.scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
    [[SDWebImageDownloader sharedDownloader] setMaxConcurrentDownloads:6];
}


@end
