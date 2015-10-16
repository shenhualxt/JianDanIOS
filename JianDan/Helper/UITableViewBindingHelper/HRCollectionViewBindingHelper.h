//
//  HRCollectionViewBindingHelper.h
//  HRTableCollectionBindingDemo
//
//  Created by Ran on 14/11/5.
//  Copyright (c) 2014年 Rannie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

typedef void (^CollectionSelectionBlock)(id model);

@interface HRCollectionViewBindingHelper : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray              *_data;
    UICollectionView            *_collectionView;
    UICollectionViewCell        *_templateCell;
    RACCommand                  *_selectCommand;
    CollectionSelectionBlock     _selectBlock;
}

+ (instancetype)bindWithCollectionView:(UICollectionView *)collectionView
                            dataSource:(RACSignal *)source
                      selectionCommand:(RACCommand *)command
                          templateCell:(UINib *)nibCell;

+ (instancetype)bindWithCollectionView:(UICollectionView *)collectionView
                            dataSource:(RACSignal *)source
                      selectionCommand:(RACCommand *)command
                 templateCellClassName:(NSString *)classCell;

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(NSArray *)source
                       didSelectionBlock:(CollectionSelectionBlock)block
                            templateCell:(UINib *)templateCellNib;

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(NSArray *)source
                       didSelectionBlock:(CollectionSelectionBlock)block
                   templateCellClassName:(NSString *)templateCellClass;

+ (instancetype)bindWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCellClass:(Class)class;

- (void)customInitialization;
- (void)reloadDataWithSourceList:(NSArray *)source;
- (UICollectionViewCell *)dequeueCellAndBindInCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// forwards the UITableViewDelegate methods
@property (weak, nonatomic) id<UICollectionViewDelegateFlowLayout> delegate;

@property (strong,nonatomic) RACDisposable *disposable;
@end
