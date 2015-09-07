//
//  HRCollectionViewBindingHelper.m
//  HRTableCollectionBindingDemo
//
//  Created by Ran on 14/11/5.
//  Copyright (c) 2014年 Rannie. All rights reserved.
//

#import "HRCollectionViewBindingHelper.h"
#import "CEReactiveView.h"

@interface HRCollectionViewBindingHelper ()
@property (nonatomic, strong) NSString * cellIdentifier;
@end

@implementation HRCollectionViewBindingHelper

#pragma mark - Initialize

//RAC
+ (instancetype)bindWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCell:(UINib *)nibCell {
    return [[self alloc] initWithCollectionView:collectionView dataSource:source selectionCommand:command templateCell:nibCell];
}

+ (instancetype)bindWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCellClassName:(NSString *)classCell {
    return [[self alloc] initWithCollectionView:collectionView dataSource:source selectionCommand:command templateCellClassName:classCell];
}

+ (instancetype)bindWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCellClass:(Class)class {
  return [[self alloc] initWithCollectionView:collectionView dataSource:source selectionCommand:command templateCellClass:class];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command {
    NSParameterAssert(collectionView);
    NSParameterAssert(source);
    self = [super init];
    if (!self) return nil;
    
    _collectionView = collectionView;
    _selectCommand = command;
    _data = [NSMutableArray array];
    
    [source subscribeNext:^(NSArray *dataList) {
        _data = [NSMutableArray arrayWithArray:dataList];
        [_collectionView reloadData];
    }];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCell:(UINib *)nibCell {
    self = [self initWithCollectionView:collectionView dataSource:source selectionCommand:command];
    if (!self) return nil;
    
    _templateCell = [[nibCell instantiateWithOwner:nil options:nil] firstObject];
    _cellIdentifier = _templateCell.reuseIdentifier;
    [_collectionView registerNib:nibCell forCellWithReuseIdentifier:_cellIdentifier];
    
    [self customInitialization];
    
    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCellClass:(Class)class {
  self = [self initWithCollectionView:collectionView dataSource:source selectionCommand:command];
  if (!self) return nil;
  self.cellIdentifier =[NSString stringWithFormat:@"%s", object_getClassName(class)];
  UINib *nib=[UINib nibWithNibName:self.cellIdentifier bundle:nil];
   _templateCell = [[nib instantiateWithOwner:nil options:nil] firstObject];
  [_collectionView registerClass:class forCellWithReuseIdentifier:_cellIdentifier];

  [self customInitialization];
  return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView dataSource:(RACSignal *)source selectionCommand:(RACCommand *)command templateCellClassName:(NSString *)classCell {
    self = [self initWithCollectionView:collectionView dataSource:source selectionCommand:command];
    if (!self) return nil;
    
    self.cellIdentifier = classCell;
    [_collectionView registerClass:NSClassFromString(classCell) forCellWithReuseIdentifier:_cellIdentifier];
    
    [self customInitialization];
    return self;
}

//Normal
+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView sourceList:(NSArray *)source didSelectionBlock:(CollectionSelectionBlock)block templateCell:(UINib *)templateCellNib {
    return [[self alloc] initForCollectionView:collectionView sourceList:source didSelectionBlock:block templateCell:templateCellNib];
}

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView sourceList:(NSArray *)source didSelectionBlock:(CollectionSelectionBlock)block templateCellClassName:(NSString *)templateCellClass {
    return [[self alloc] initForCollectionView:collectionView sourceList:source didSelectionBlock:block templateCellClassName:templateCellClass];
}

- (instancetype)initForCollectionView:(UICollectionView *)collectionView sourceList:(NSArray *)source didSelectionBlock:(CollectionSelectionBlock)block {
    NSParameterAssert(collectionView);
    NSParameterAssert(source);
    
    self = [super init];
    if (!self) return nil;
    
    _collectionView = collectionView;
    _data = [NSMutableArray arrayWithArray:source];
    _selectBlock = [block copy];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    return self;
}

- (instancetype)initForCollectionView:(UICollectionView *)collectionView sourceList:(NSArray *)source didSelectionBlock:(CollectionSelectionBlock)block templateCell:(UINib *)templateCellNib {
    self = [self initForCollectionView:collectionView sourceList:source didSelectionBlock:block];
    if (!self) return nil;
    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    _cellIdentifier = _templateCell.reuseIdentifier;
    [_collectionView registerNib:templateCellNib forCellWithReuseIdentifier:_cellIdentifier];
    
    [self customInitialization];
    return self;
}

- (instancetype)initForCollectionView:(UICollectionView *)collectionView sourceList:(NSArray *)source didSelectionBlock:(CollectionSelectionBlock)block templateCellClassName:(NSString *)templateCellClass {
    self = [self initForCollectionView:collectionView sourceList:source didSelectionBlock:block];
    if (!self) return nil;
    self.cellIdentifier = templateCellClass;
    [_collectionView registerClass:NSClassFromString(templateCellClass) forCellWithReuseIdentifier:templateCellClass];
    
    [self customInitialization];
    return self;
}

- (void)customInitialization {
    //abstract...
}

#pragma mark - DataSource and Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueCellAndBindInCollectionView:collectionView indexPath:indexPath];
}

- (UICollectionViewCell *)dequeueCellAndBindInCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    id<CEReactiveView> cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    if (!cell) {
      cell=(id<CEReactiveView>)_templateCell;
    }

    if ([cell respondsToSelector:@selector(bindViewModel:)]) {
      [cell bindViewModel:_data[indexPath.row]];
    }
    return (UICollectionViewCell *)cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectBlock) {
        _selectBlock(_data[indexPath.row]);
    } else if (_selectCommand) {
        [_selectCommand execute:_data[indexPath.row]];
    }
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
      return [self.delegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
  return [collectionView cellForItemAtIndexPath:indexPath].frame.size;
}


#pragma mark - Custon Action
- (void)reloadDataWithSourceList:(NSArray *)source
{
    if (source) {
        _data = [NSMutableArray arrayWithArray:source];
    }
    [_collectionView reloadData];
}

@end
