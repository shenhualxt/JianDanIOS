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
    [[SDWebImageDownloader sharedDownloader] setMaxConcurrentDownloads:6];
}

#pragma mark-开速滑动优化

//按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSIndexPath *ip = [_tableView indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
//    NSIndexPath *cip = [[_tableView indexPathsForVisibleRows] firstObject];
//    NSInteger skipCount = 8;
//    if (labs(cip.row - ip.row) > skipCount) {
//        NSArray * temp = [_tableView indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, _tableView.frame.size.width, _tableView.frame.size.height)];
//        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
//        if (velocity.y < 0) {
//            NSIndexPath *indexPath = [temp lastObject];
//            if (indexPath.row + 3 < _data.count) {
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row + 2 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row + 3 inSection:0]];
//            }
//        } else {
//            NSIndexPath *indexPath = [temp firstObject];
//            if (indexPath.row > 3) {
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row - 3 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row - 2 inSection:0]];
//                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
//            }
//        }
//        [needLoadArr addObjectsFromArray:arr];
//    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    scrollToToping = YES;
    return YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    scrollToToping = NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    scrollToToping = NO;
}

////用户触摸时第一时间加载内容
//- (void)hitTest{
//    if (!scrollToToping) {
//        [needLoadArr removeAllObjects];
//        [self loadContent];
//    }
//}
//
//- (void)loadContent{
//    if (scrollToToping) {
//        return;
//    }
//    if (_tableView.indexPathsForVisibleRows.count<=0) {
//        return;
//    }
//    if (_tableView.visibleCells&&_tableView.visibleCells.count>0) {
//        for (id temp in [_tableView.visibleCells copy]) {
//            id<CEReactiveView> cell = temp;
//             NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell *)cell];
//            [cell bindViewModel:_data[indexPath.row] forIndexPath:indexPath];
//        }
//    }
//}


@end
