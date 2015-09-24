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
#import "CEObservableMutableArray.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface CETableViewBindingHelper () <UITableViewDataSource, UITableViewDelegate, CEObservableMutableArrayDelegate>

@property(nonatomic, readwrite, assign) struct delegateMethodsCaching {

// UITableViewDelegate
//Configuring Rows for the Table View
    uint heightForRowAtIndexPath:1;
    uint estimatedHeightForRowAtIndexPath:1;
    uint indentationLevelForRowAtIndexPath:1;
    uint willDisplayCellForRowAtIndexPath:1;

//Managing Accessory Views
    uint editActionsForRowAtIndexPath:1;
    uint accessoryButtonTappedForRowWithIndexPath:1;

//Managing Selections
    uint willSelectRowAtIndexPath:1;
    uint didSelectRowAtIndexPath:1;
    uint willDeselectRowAtIndexPath:1;
    uint didDeselectRowAtIndexPath:1;

//Modifying the Header and Footer of Sections
    uint viewForHeaderInSection:1;
    uint viewForFooterInSection:1;
    uint heightForHeaderInSection:1;
    uint estimatedHeightForHeaderInSection:1;
    uint heightForFooterInSection:1;
    uint estimatedHeightForFooterInSection:1;
    uint willDisplayHeaderViewForSection:1;
    uint willDisplayFooterViewForSection:1;

//Editing Table Rows
    uint willBeginEditingRowAtIndexPath:1;
    uint didEndEditingRowAtIndexPath:1;
    uint editingStyleForRowAtIndexPath:1;
    uint titleForDeleteConfirmationButtonForRowAtIndexPath:1;
    uint shouldIndentWhileEditingRowAtIndexPath:1;

//Reordering Table Rows
    uint targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath:1;

//Tracking the Removal of Views
    uint didEndDisplayingCellForRowAtIndexPath:1;
    uint didEndDisplayingHeaderViewForSection:1;
    uint didEndDisplayingFooterViewForSection:1;

//Copying and Pasting Row Content
    uint shouldShowMenuForRowAtIndexPath:1;
    uint canPerformActionForRowAtIndexPathWithSender:1;
    uint performActionForRowAtIndexPathWithSender:1;

//Managing Table View Highlighting
    uint shouldHighlightRowAtIndexPath:1;
    uint didHighlightRowAtIndexPath:1;
    uint didUnhighlightRowAtIndexPath:1;

} delegateRespondsTo;

@property(nonatomic, readwrite, assign) struct scrollViewDelegateMethodsCaching {
// UIScrollViewDelegate
//Responding to Scrolling and Dragging
uint scrollViewDidScroll:1;
uint scrollViewWillBeginDragging:1;
uint scrollViewWillEndDraggingWithVelocityTargetContentOffset:1;
uint scrollViewDidEndDraggingWillDecelerate:1;
uint scrollViewShouldScrollToTop:1;
uint scrollViewDidScrollToTop:1;
uint scrollViewWillBeginDecelerating:1;
uint scrollViewDidEndDecelerating:1;

//Managing Zooming
uint viewForZoomingInScrollView:1;
uint scrollViewWillBeginZoomingWithView:1;
uint scrollViewDidEndZoomingWithViewAtScale:1;
uint scrollViewDidZoom:1;

//Responding to Scrolling Animations
uint scrollViewDidEndScrollingAnimation:1;
} scrollViewDelegateRespondsTo;

@end

@implementation CETableViewBindingHelper {
    UITableView *_tableView;
    NSArray *_data;
    UITableViewCell *_templateCell;
    RACCommand *_selection;
    NSString *_reuseIdentifier;
    UIView *_customView;
}

#pragma  mark - initialization

- (instancetype)initWithTableView:(UITableView *)tableView sourceSignal:(RACSignal *)source selectionCommand:(RACCommand *)selection {
    if (self = [super init]) {
        _tableView = tableView;
        _data = [NSArray array];
        _selection = selection;

        [source subscribeNext:^(id x) {
            if ([x isKindOfClass:[CEObservableMutableArray class]]) {
                ((CEObservableMutableArray *) x).delegate = self;
            }
            if (self->_data != nil && [self->_data isKindOfClass:[CEObservableMutableArray class]]) {
                ((CEObservableMutableArray *) self->_data).delegate = nil;
            }
            self->_data = x;
            [self->_tableView reloadData];
        }];

        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        self.delegate = nil;
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView sourceSignal:(RACSignal *)source selectionCommand:(RACCommand *)selection customCellClass:(Class)clazz {
    self = [self initWithTableView:tableView sourceSignal:source selectionCommand:selection];
    if (self) {
        [self switchCellClass:clazz];
    }
    return self;
}

-(void)switchCellClass:(Class)clazz{
    _reuseIdentifier = NSStringFromClass(clazz);
    UINib *nib = [UINib nibWithNibName:_reuseIdentifier bundle:nil];
    _templateCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
    [_tableView registerNib:nib forCellReuseIdentifier:_reuseIdentifier];
    _tableView.rowHeight = _templateCell.bounds.size.height;
}

- (instancetype)initWithTableView:(UITableView *)tableView sourceSignal:(RACSignal *)source selectionCommand:(RACCommand *)selection templateCellClass:(Class)clazz {
    self = [self initWithTableView:tableView sourceSignal:source selectionCommand:selection];
    if (self) {
        _reuseIdentifier = [NSString stringWithFormat:@"%s", object_getClassName(clazz)];
        UITableViewCell *cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseIdentifier];
        _templateCell = cell;
        [_tableView registerClass:[cell class] forCellReuseIdentifier:_reuseIdentifier];
        _tableView.rowHeight = _templateCell.bounds.size.height; // use the template cell to set the row height
    }
    return self;
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

#pragma mark - Setters
-(void)setScrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate{
    if (self.scrollViewDelegate != scrollViewDelegate) {
        _scrollViewDelegate = scrollViewDelegate;
        
    struct scrollViewDelegateMethodsCaching newMethodCaching;
    // UIScrollViewDelegate
    //Responding to Scrolling and Dragging
    newMethodCaching.scrollViewDidScroll = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)];
    newMethodCaching.scrollViewWillBeginDragging = [_scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
    newMethodCaching.scrollViewWillEndDraggingWithVelocityTargetContentOffset = [_scrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)];
    newMethodCaching.scrollViewDidEndDraggingWillDecelerate = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
    newMethodCaching.scrollViewShouldScrollToTop = [_scrollViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)];
    newMethodCaching.scrollViewDidScrollToTop = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)];
    newMethodCaching.scrollViewWillBeginDecelerating = [_scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)];
    newMethodCaching.scrollViewDidEndDecelerating = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
    
    //Managing Zooming
    newMethodCaching.viewForZoomingInScrollView = [_scrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)];
    newMethodCaching.scrollViewWillBeginZoomingWithView = [_scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)];
    newMethodCaching.scrollViewDidEndZoomingWithViewAtScale = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)];
    newMethodCaching.scrollViewDidZoom = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)];
    
    //Responding to Scrolling Animations
    newMethodCaching.scrollViewDidEndScrollingAnimation = [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)];
    self.scrollViewDelegateRespondsTo=newMethodCaching;
    }
}

- (void)setDelegate:(id <UITableViewDelegate>)delegate {
    if (self.delegate != delegate) {
        _delegate = delegate;

        struct delegateMethodsCaching newMethodCaching;
        // UITableViewDelegate
        //Configuring Rows for the Table View
        newMethodCaching.heightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
        newMethodCaching.estimatedHeightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)];
        newMethodCaching.indentationLevelForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)];
        newMethodCaching.willDisplayCellForRowAtIndexPath = [delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)];

        //Managing Accessory Views
        newMethodCaching.editActionsForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)];
        newMethodCaching.accessoryButtonTappedForRowWithIndexPath = [_delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)];

        //Managing Selections
        newMethodCaching.willSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)];
        newMethodCaching.didSelectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
        newMethodCaching.willDeselectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)];
        newMethodCaching.didDeselectRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)];

        //Modifying the Header and Footer of Sections
        newMethodCaching.viewForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
        newMethodCaching.viewForFooterInSection = [_delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
        newMethodCaching.heightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
        newMethodCaching.estimatedHeightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)];
        newMethodCaching.heightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
        newMethodCaching.estimatedHeightForFooterInSection = [_delegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)];
        newMethodCaching.willDisplayHeaderViewForSection = [_delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)];
        newMethodCaching.willDisplayFooterViewForSection = [_delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)];

        //Editing Table Rows
        newMethodCaching.willBeginEditingRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)];
        newMethodCaching.didEndEditingRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)];
        newMethodCaching.editingStyleForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)];
        newMethodCaching.titleForDeleteConfirmationButtonForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)];
        newMethodCaching.shouldIndentWhileEditingRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)];

        //Reordering Table Rows
        newMethodCaching.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath = [_delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)];

        //Tracking the Removal of Views
        newMethodCaching.didEndDisplayingCellForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)];
        newMethodCaching.didEndDisplayingHeaderViewForSection = [_delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)];
        newMethodCaching.didEndDisplayingFooterViewForSection = [_delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)];

        //Copying and Pasting Row Content
        newMethodCaching.shouldShowMenuForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)];
        newMethodCaching.canPerformActionForRowAtIndexPathWithSender = [_delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)];
        newMethodCaching.performActionForRowAtIndexPathWithSender = [_delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)];

        //Managing Table View Highlighting
        newMethodCaching.shouldHighlightRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)];
        newMethodCaching.didHighlightRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)];
        newMethodCaching.didUnhighlightRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)];

        self.delegateRespondsTo = newMethodCaching;
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <CEReactiveView> cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    if (!cell) {
        cell = (id <CEReactiveView>) _templateCell;
    }

    NSAssert([cell respondsToSelector:@selector(bindViewModel:forIndexPath:)], @"The cells supplied to the CETableViewBindingHelper must implement the CEReactiveView protocol");

    if ([cell respondsToSelector:@selector(bindViewModel:forIndexPath:)]) {
            [cell bindViewModel:_data[indexPath.row] forIndexPath:indexPath];
    }

    return (UITableViewCell *) cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([_data isKindOfClass:[CEObservableMutableArray class]]) {
            [((CEObservableMutableArray *) _data) removeObjectAtIndex:indexPath.row];
        } else {
            NSLog(@"The array bound to the table view must be a CEObservableMutableArray");
        }
    }
}


#pragma mark - UITableViewDelegate methods
#pragma mark Configuring Rows for the Table View

- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRowAtIndexPath = tableView.rowHeight;
    if (_isDynamicHeight) {
        heightForRowAtIndexPath=[_tableView fd_heightForCellWithIdentifier:_reuseIdentifier cacheByIndexPath:indexPath configuration:^(id<CEReactiveView> cell) {
            if ([cell respondsToSelector:@selector(bindViewModel:forIndexPath:)]) {
                [cell bindViewModel:_data[indexPath.row] forIndexPath:indexPath];
            }
        }];
    }
    
    if (self.delegateRespondsTo.heightForRowAtIndexPath) {
        heightForRowAtIndexPath = [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return heightForRowAtIndexPath;
}

- (CGFloat)            tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat estimatedHeightForRowAtIndexPath = tableView.rowHeight;

    if (self.delegateRespondsTo.estimatedHeightForRowAtIndexPath) {
        estimatedHeightForRowAtIndexPath = [self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return estimatedHeightForRowAtIndexPath;
}

- (NSInteger)           tableView:(UITableView *)tableView
indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger indentationLevelForRowAtIndexPath = 0;

    if (self.delegateRespondsTo.indentationLevelForRowAtIndexPath == 1) {
        indentationLevelForRowAtIndexPath = [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    return indentationLevelForRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegateRespondsTo.willDisplayCellForRowAtIndexPath == 1) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark Managing Accessory Views

- (NSArray *)      tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *editActionsForRowAtIndexPath = nil;

    if (_delegateRespondsTo.editActionsForRowAtIndexPath == 1) {
        editActionsForRowAtIndexPath = [self.delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return editActionsForRowAtIndexPath;
}

- (void)                       tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.accessoryButtonTappedForRowWithIndexPath == 1) {
        [self.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

#pragma mark Managing Selections

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *willSelectRowAtIndexPath = indexPath;

    if (_delegateRespondsTo.willSelectRowAtIndexPath == 1) {
        willSelectRowAtIndexPath = [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return willSelectRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // execute the command
    RACTuple *turple=[RACTuple tupleWithObjects:_data[indexPath.row],indexPath, nil];
    [_selection execute:turple];

    // forward the delegate method
    if (_delegateRespondsTo.didSelectRowAtIndexPath == 1) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView
willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *willDeselectRowAtIndexPath = indexPath;

    if (_delegateRespondsTo.willDeselectRowAtIndexPath == 1) {
        willDeselectRowAtIndexPath = [self.delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return willDeselectRowAtIndexPath;
}

- (void)        tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.didDeselectRowAtIndexPath == 1) {
        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

#pragma mark Modifying the Header and Footer of Sections

- (UIView *) tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *viewForHeaderInSection = nil;

    if (_delegateRespondsTo.viewForHeaderInSection == 1) {
        viewForHeaderInSection = [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    return viewForHeaderInSection;
}

- (UIView *) tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section {
    UIView *viewForFooterInSection = nil;

    if (_delegateRespondsTo.viewForFooterInSection == 1) {
        viewForFooterInSection = [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    return viewForFooterInSection;
}

- (CGFloat)    tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat heightForHeaderInSection = 0.0f;

    if (_delegateRespondsTo.heightForHeaderInSection == 1) {
        heightForHeaderInSection = [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    return heightForHeaderInSection;
}

- (CGFloat)             tableView:(UITableView *)tableView
estimatedHeightForHeaderInSection:(NSInteger)section {
    CGFloat estimatedHeightForHeaderInSection = 0.0f;

    if (_delegateRespondsTo.estimatedHeightForHeaderInSection == 1) {
        estimatedHeightForHeaderInSection = [self.delegate tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    return estimatedHeightForHeaderInSection;
}


- (CGFloat)    tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    CGFloat heightForFooterInSection = 0.0f;

    if (_delegateRespondsTo.heightForFooterInSection == 1) {
        heightForFooterInSection = [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    return heightForFooterInSection;
}


- (CGFloat)             tableView:(UITableView *)tableView
estimatedHeightForFooterInSection:(NSInteger)section {
    CGFloat estimatedHeightForFooterInSection = 0.0f;

    if (_delegateRespondsTo.estimatedHeightForFooterInSection == 1) {
        estimatedHeightForFooterInSection = [self.delegate tableView:tableView estimatedHeightForFooterInSection:section];
    }
    return estimatedHeightForFooterInSection;
}

- (void)    tableView:(UITableView *)tableView
willDisplayHeaderView:(UIView *)view
           forSection:(NSInteger)section {
    if (_delegateRespondsTo.willDisplayHeaderViewForSection == 1) {
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)    tableView:(UITableView *)tableView
willDisplayFooterView:(UIView *)view
           forSection:(NSInteger)section {
    if (_delegateRespondsTo.willDisplayFooterViewForSection == 1) {
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

#pragma mark Editing Table Rows

- (void)             tableView:(UITableView *)tableView
willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.willBeginEditingRowAtIndexPath == 1) {
        [self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)          tableView:(UITableView *)tableView
didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.didEndEditingRowAtIndexPath == 1) {
        [self.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle editingStyleForRowAtIndexPath = [tableView cellForRowAtIndexPath:indexPath].editing == YES ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;

    if (_delegateRespondsTo.editingStyleForRowAtIndexPath == 1) {
        editingStyleForRowAtIndexPath = [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return editingStyleForRowAtIndexPath;
}

- (NSString *)                          tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleForDeleteConfirmationButtonForRowAtIndexPath = NSLocalizedString(@"Delete", @"Delete");

    if (_delegateRespondsTo.titleForDeleteConfirmationButtonForRowAtIndexPath == 1) {
        titleForDeleteConfirmationButtonForRowAtIndexPath = [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return titleForDeleteConfirmationButtonForRowAtIndexPath;
}

- (BOOL)                     tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldIndentWhileEditingRowAtIndexPath = YES;

    if (_delegateRespondsTo.shouldIndentWhileEditingRowAtIndexPath == 1) {
        shouldIndentWhileEditingRowAtIndexPath = [self.delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    return shouldIndentWhileEditingRowAtIndexPath;
}

#pragma mark Reordering Table Rows

- (NSIndexPath *)              tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                     toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *toProposedIndexPath = proposedDestinationIndexPath;

    if (_delegateRespondsTo.targetIndexPathForMoveFromRowAtIndexPathToProposedIndexPath == 1) {
        toProposedIndexPath = [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return toProposedIndexPath;
}

#pragma mark Tracking the Removal of Views

- (void)   tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
   forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.didEndDisplayingCellForRowAtIndexPath == 1) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)         tableView:(UITableView *)tableView
didEndDisplayingHeaderView:(UIView *)view
                forSection:(NSInteger)section {
    if (_delegateRespondsTo.didEndDisplayingHeaderViewForSection == 1) {
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)         tableView:(UITableView *)tableView
didEndDisplayingFooterView:(UIView *)view
                forSection:(NSInteger)section {
    if (_delegateRespondsTo.didEndDisplayingFooterViewForSection == 1) {
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

#pragma mark Copying and Pasting Row Content

- (BOOL)              tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldShowMenuForRowAtIndexPath = NO;

    if (_delegateRespondsTo.shouldShowMenuForRowAtIndexPath == 1) {
        shouldShowMenuForRowAtIndexPath = [self.delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    return shouldShowMenuForRowAtIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender {
    BOOL canPerformAction = NO;

    if (_delegateRespondsTo.canPerformActionForRowAtIndexPathWithSender == 1) {
        canPerformAction = [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return canPerformAction;
}

- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender {
    if (_delegateRespondsTo.performActionForRowAtIndexPathWithSender == 1) {
        [self.delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

#pragma mak Managing Table View Highlighting

- (BOOL)            tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldHighlightRowAtIndexPath = YES;

    if (_delegateRespondsTo.shouldHighlightRowAtIndexPath == 1) {
        shouldHighlightRowAtIndexPath = [self.delegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return shouldHighlightRowAtIndexPath;
}

- (void)         tableView:(UITableView *)tableView
didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.didHighlightRowAtIndexPath == 1) {
        [self.delegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)           tableView:(UITableView *)tableView
didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateRespondsTo.didUnhighlightRowAtIndexPath == 1) {
        [self.delegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate
#pragma mark Responding to Scrolling and Dragging

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewDidScroll) {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewWillBeginDragging) {
        [self.scrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_scrollViewDelegateRespondsTo.scrollViewWillEndDraggingWithVelocityTargetContentOffset) {
        [self.scrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (_scrollViewDelegateRespondsTo.scrollViewDidEndDraggingWillDecelerate) {
        [self.scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    BOOL scrollViewShouldScrollToTop = YES;

    if (_scrollViewDelegateRespondsTo.scrollViewShouldScrollToTop) {
        scrollViewShouldScrollToTop = [self.scrollViewDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return scrollViewShouldScrollToTop;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewDidScrollToTop) {
        [self.scrollViewDelegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewWillBeginDecelerating) {
        [self.scrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewDidEndDecelerating) {
        [self.scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark Managing Zooming

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView *viewForZoomingInScrollView = nil;

    if (_scrollViewDelegateRespondsTo.viewForZoomingInScrollView) {
        viewForZoomingInScrollView = [self.scrollViewDelegate viewForZoomingInScrollView:scrollView];
    }
    return viewForZoomingInScrollView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView
                          withView:(UIView *)view {
    if (_scrollViewDelegateRespondsTo.scrollViewWillBeginZoomingWithView) {
        [self.scrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale {
    if (_scrollViewDelegateRespondsTo.scrollViewDidEndZoomingWithViewAtScale) {
        [self.scrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewDidZoom) {
        [self.scrollViewDelegate scrollViewDidZoom:scrollView];
    }
}

#pragma mark Responding to Scrolling Animations

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_scrollViewDelegateRespondsTo.scrollViewDidEndScrollingAnimation) {
        [self.scrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

#pragma mark - CEObservableMutableArrayDelegate methods

- (void)array:(CEObservableMutableArray *)array didAddItemAtIndex:(NSUInteger)index {
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)array:(CEObservableMutableArray *)array didRemoveItemAtIndex:(NSUInteger)index {
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)array:(CEObservableMutableArray *)array didReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
}

@end
