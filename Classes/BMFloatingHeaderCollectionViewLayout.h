//
//  BMFloatingHeaderCollectionViewLayout.h
//
//  Created by Adam Iredale on 15/11/2013.
//  Copyright (c) 2013 Bionic Monocle Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Views

#import "BMReusableContainerView.h"

extern NSString *const BMFloatingHeaderCollectionViewLayoutHeaderTitleKind;
extern NSString *const BMFloatingHeaderCollectionViewLayoutHeaderDetailKind;
extern NSString *const BMFloatingHeaderCollectionViewLayoutPlaceholderKind;

@class BMFloatingHeaderCollectionViewLayout;

/**
 *  Used by BMFloatingHeaderCollectionViewLayout to find the predetermined sizes of the items,
 *  and supplimentary views, if applicable. BMFloatingHeaderCollectionViewLayout checks to see
 *  if the collection view's datasource supports this protocol.
 */
@protocol BMFloatingHeaderCollectionViewLayoutDelegate <UICollectionViewDelegate>

- (CGFloat)collectionViewLayout:(BMFloatingHeaderCollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  Base class for taking care of a bunch of grunt work in UICollectionViewLayout
 */

@interface BMFloatingHeaderCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) UIEdgeInsets itemInsets;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGFloat headerTitleViewHeight;
@property (nonatomic, assign) CGFloat headerDetailViewHeight;

@end
