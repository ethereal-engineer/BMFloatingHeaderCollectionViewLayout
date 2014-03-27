//
//  BMFloatingHeaderCollectionViewLayoutInvalidationContext.h
//  Pods
//
//  Created by Adam Iredale on 28/03/2014.
//
//

#import <UIKit/UIKit.h>

@interface BMFloatingHeaderCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic, assign) BOOL invalidateOnlyDetailHeader;

- (instancetype)initWithInvalidationForDetailHeaderOnly:(BOOL)invalidateDetailHeaderOnly;

@end
