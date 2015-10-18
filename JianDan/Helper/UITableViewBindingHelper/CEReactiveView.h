//
//  RWView.h
//  RWTwitterSearch
//
//  Created by Colin Eberhardt on 25/04/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CETableViewBindingHelper.h"

/// A protocol which is adopted by views which are backed by view models.
@protocol CEReactiveView <NSObject>

@optional
- (void)bindViewModel:(id)viewModel;

- (void)bindViewModel:(id)viewModel forIndexPath:(NSIndexPath *)indexPath;

- (void)bindViewModel:(CETableViewBindingHelper *)helper viewModel:(id)viewModel forIndexPath:(NSIndexPath *)indexPath;

- (void)loadImage:(id)viewModel forIndexPath:(NSIndexPath *)indexPath helper:(CETableViewBindingHelper *)helper;

-(void)clear;

@end
