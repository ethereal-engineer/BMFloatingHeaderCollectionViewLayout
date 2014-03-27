//
//  BMFloatingHeaderCollectionViewLayoutInvalidationContext.m
//  Pods
//
//  Created by Adam Iredale on 28/03/2014.
//
//

#import "BMFloatingHeaderCollectionViewLayoutInvalidationContext.h"

@implementation BMFloatingHeaderCollectionViewLayoutInvalidationContext

#pragma mark - Init

- (instancetype)initWithInvalidationForDetailHeaderOnly:(BOOL)invalidateDetailHeaderOnly
{
    self = [super init];
    if (self)
    {
        self.invalidateOnlyDetailHeader = invalidateDetailHeaderOnly;
    }
    return self;
}

#pragma mark - UICollectionViewLayoutInvalidationContext

#pragma mark Init

- (instancetype)init
{
    // By default, invalidate everything
    self = [self initWithInvalidationForDetailHeaderOnly:NO];
    return self;
}

@end
