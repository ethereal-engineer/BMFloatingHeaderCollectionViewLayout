//
//  HSCollectionViewLayout.m
//  cvtest
//
//  Created by Adam Iredale on 15/11/2013.
//  Copyright (c) 2013 Bionic Monocle Pty Ltd. All rights reserved.
//

#import "BMFloatingHeaderCollectionViewLayout.h"

#pragma mark - Invalidation Context

#import "BMFloatingHeaderCollectionViewLayoutInvalidationContext.h"

NSString *const BMFloatingHeaderCollectionViewLayoutHeaderTitleKind   = @"BMFloatingHeaderCollectionViewLayoutHeaderTitleKind";
NSString *const BMFloatingHeaderCollectionViewLayoutHeaderDetailKind  = @"BMFloatingHeaderCollectionViewLayoutHeaderDetailKind";
NSString *const BMFloatingHeaderCollectionViewLayoutPlaceholderKind   = @"BMFloatingHeaderCollectionViewLayoutPlaceholderKind";

#pragma mark - BMFloatingHeaderCollectionViewLayout

@interface BMFloatingHeaderCollectionViewLayout ()

@property (nonatomic, strong) UICollectionViewLayoutAttributes *headerTitleViewAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *headerDetailViewAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *placeHolderViewAttributes;

@property (nonatomic, strong) NSMapTable *cellAttributes;
@property (nonatomic, strong) NSMutableSet *allAttributes;

@property (nonatomic, assign) CGRect contentFrame;
/**
 *  Reference bounds size to know when to invalidate all
 */
@property (nonatomic, assign) CGSize boundsSize;
/**
 *  Set when inspecting the custom invalidation context. If YES, all will be recalculated, 
 *  otherwise, just the detail header
 */
@property (nonatomic, assign) BOOL shouldInvalidateAll;

@end

@implementation BMFloatingHeaderCollectionViewLayout

#pragma mark - UICollectionViewLayout

#pragma mark Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupLayout];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout
{
    self.itemInsets             = UIEdgeInsetsMake(5, 5, 5, 5);
    self.contentInsets          = _itemInsets;
    self.cellAttributes         = [NSMapTable strongToStrongObjectsMapTable];
    self.allAttributes          = [[NSMutableSet alloc] init];
    
    NSIndexPath *zeroIndexPath  = [NSIndexPath indexPathForItem:0 inSection:0];
    
    self.headerDetailViewAttributes =
    ({
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:BMFloatingHeaderCollectionViewLayoutHeaderDetailKind
                                                                                                                      withIndexPath:zeroIndexPath];
        attributes.zIndex = 99;
        attributes;
    });
    self.headerTitleViewAttributes  =
    ({
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:BMFloatingHeaderCollectionViewLayoutHeaderTitleKind
                                                                                                                      withIndexPath:zeroIndexPath];
        attributes.zIndex = 99;
        attributes;
    });
    self.placeHolderViewAttributes  =
    ({
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:BMFloatingHeaderCollectionViewLayoutPlaceholderKind
                                                                                                                      withIndexPath:zeroIndexPath];
        attributes.zIndex = 98;
        attributes;
    });
}

#pragma mark Attributes

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_cellAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:BMFloatingHeaderCollectionViewLayoutHeaderTitleKind])
    {
        return _headerTitleViewAttributes;
    }
    else if ([kind isEqualToString:BMFloatingHeaderCollectionViewLayoutHeaderDetailKind])
    {
        return _headerDetailViewAttributes;
    }
    else if ([kind isEqualToString:BMFloatingHeaderCollectionViewLayoutPlaceholderKind])
    {
        return _placeHolderViewAttributes;
    }
    else
    {
        return nil;
    }
}

#pragma mark Invalidation

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    // Invalidate with custom options - only the detail header (which is calculated in stage two)
    // unless the width of the collection view doesn't match the reference width
    [self invalidateLayoutWithContext:[[BMFloatingHeaderCollectionViewLayoutInvalidationContext alloc] initWithInvalidationForDetailHeaderOnly:(newBounds.size.width == self.boundsSize.width)]];
    
    // We won't use the default invalidation context here
    return NO;
}

- (void)invalidateLayoutWithContext:(BMFloatingHeaderCollectionViewLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
    
    // If we are invalidating everything then we do that - otherwise we only invalidate the
    // detail header
    self.shouldInvalidateAll = !context.invalidateOnlyDetailHeader;
}

+ (Class)invalidationContextClass
{
    return [BMFloatingHeaderCollectionViewLayoutInvalidationContext class];
}

#pragma mark Layout Process

/**
 *  STEP ONE
 *  --------
 *  - perform whatever calculations are needed to determine the position of the cells and views
 *  - compute enough information to be able to deliver the overall size of the content area in STEP TWO
 *
 *  N.B. When your app is not dealing with thousands of items, it makes sense to create layout attribute
 *  instances while preparing the layout, because the layout information can be cached and referenced rather
 *  than computed on the fly. If the costs of computing all the attributes up front outweighs the benefits
 *  of caching in your app, it is just as easy to create attributes in the moment when they are requested.
 */
- (void)prepareLayout
{
    // Only prepare the layout from scratch if we are invalidating ALL, otherwise skip this step
    if (!_shouldInvalidateAll)
    {
        return;
    }
    
    // Register supplimentary views
    [self.collectionView registerClass:[BMReusableContainerView class]
            forSupplementaryViewOfKind:BMFloatingHeaderCollectionViewLayoutHeaderTitleKind
                   withReuseIdentifier:BMFloatingHeaderCollectionViewLayoutHeaderTitleKind];
    [self.collectionView registerClass:[BMReusableContainerView class]
            forSupplementaryViewOfKind:BMFloatingHeaderCollectionViewLayoutHeaderDetailKind
                   withReuseIdentifier:BMFloatingHeaderCollectionViewLayoutHeaderDetailKind];
    [self.collectionView registerClass:[BMReusableContainerView class]
            forSupplementaryViewOfKind:BMFloatingHeaderCollectionViewLayoutPlaceholderKind
                   withReuseIdentifier:BMFloatingHeaderCollectionViewLayoutPlaceholderKind];
    
    // Clear priors
    [_cellAttributes removeAllObjects];
    [_allAttributes removeAllObjects];
    // Reset the content frame
    self.contentFrame = CGRectZero;
    // Calculate the lot
    [self calculateHeaderTitleLayoutAttributes];
    [self calculateHeaderDetailLayoutAttributes:NO];
    [self calculateItemLayoutAttributes];
    // Update the reference bounds size
    self.boundsSize = self.collectionView.bounds.size;
}

/**
 *  STEP TWO
 *  --------
 *
 *  @return Size of the entire content panel
 */
- (CGSize)collectionViewContentSize
{
    return self.contentFrame.size;
}

/**
 *  STEP THREE
 *  ----------
 *
 *  @param rect The current (or upcoming) rectangle that will be visible in the collection view
 *
 *  @return Array of layout attributes for all kinds of items in the specified rectangle
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Get all attributes that intersect the rectangle requested
    NSArray *attributes =
    ({
        NSSet *intersectingAttributes = [_allAttributes objectsPassingTest:^BOOL(id obj, BOOL *stop)
        {
            return CGRectIntersectsRect(rect, [obj frame]);
        }];
        [intersectingAttributes allObjects];
    });
    
    // Recalculate the detail header position
    [self calculateHeaderDetailLayoutAttributes:YES];
    // And include it too if it matches
    if (CGRectIntersectsRect(rect, _headerDetailViewAttributes.frame))
    {
        attributes = [attributes arrayByAddingObject:_headerDetailViewAttributes];
    }
    
    return attributes;
}

/**
 *  N.B. After layout finishes, the attributes of your cells and views remain the same until you or the
 *  collection view invalidates the layout (then the layout process starts over).
 *
 *  Invalidation happens when (on the next view cycle)...
 *
 *  - invalidateLayout is called manually (it triggers a dirty flag)
 *  - the user scrolls the content and shouldInvalidateLayoutForBoundsChange: returns YES
 */

#pragma mark - Accessors

- (void)setHeaderTitleViewHeight:(CGFloat)headerTitleViewHeight
{
    _headerTitleViewHeight = headerTitleViewHeight;
    [self invalidateLayout];
}

- (void)setHeaderDetailViewHeight:(CGFloat)headerDetailViewHeight
{
    _headerDetailViewHeight = headerDetailViewHeight;
    [self invalidateLayout];
}

- (void)setItemInsets:(UIEdgeInsets)itemInsets
{
    _itemInsets = itemInsets;
    [self invalidateLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self invalidateLayout];
}

#pragma mark - Calculation (Private)

/**
 *  Given the prior item's frame (or starting with zero prior item), calculate the frame for an item
 *
 *  @param indexPath      NSIndexPath of the item
 *  @param priorItemFrame The last calculated frame (item frames are calculated sequentially)
 *
 *  @note After calculating all item frames, the content size must also append one final item inset and
 *  content inset to arrive at the correct total size
 *
 *  @return The frame for this item
 */

- (CGRect)calculateFrameForCellAtIndexPath:(NSIndexPath *)indexPath priorItemFrame:(CGRect)priorItemFrame
{
    CGRect frame;
    
    NSAssert([self.collectionView.delegate conformsToProtocol:@protocol(BMFloatingHeaderCollectionViewLayoutDelegate)],
             @"UICollectionView delegate must conform to BMFloatingHeaderCollectionViewLayoutDelegate");
    
    CGFloat itemHeight = [(id <BMFloatingHeaderCollectionViewLayoutDelegate>)self.collectionView.delegate collectionViewLayout:self
                                                                                        heightForItemAtIndexPath:indexPath];
    
    if (CGRectEqualToRect(priorItemFrame, CGRectZero))
    {
        // Fixed total width is the width of the collection view bounds
        CGFloat totalWidth = self.collectionView.bounds.size.width;
        // Left inset is the sum of left insets
        CGFloat leftInset = _contentInsets.left + _itemInsets.left;
        // Right inset is the sum of right insets
        CGFloat rightInset = _contentInsets.right + _itemInsets.right;
        // Top inset is the sum of top insets PLUS the header title height and header detail height
        CGFloat topInset = _contentInsets.top + _itemInsets.top + _headerTitleViewHeight + _headerDetailViewHeight;
        
        // The item width is the total width less the left and right insets
        CGFloat itemWidth = totalWidth - leftInset - rightInset;
        
        // Calculate the first cell's frame
        frame = CGRectMake(leftInset, topInset, itemWidth, itemHeight);
    }
    else
    {
        // Calculate this cell's frame based on the prior cell's frame
        // Offset by the height of the prior frame and then add in its bottom and this item's top inset
        frame = CGRectOffset(priorItemFrame, 0.0, priorItemFrame.size.height + _itemInsets.top + _itemInsets.bottom);
        // Swap out the height of the frame for the one from the delegate
        frame.size.height = itemHeight;
    }
    
    // Store the computed frame
    [self storeFrame:frame forIndexPath:indexPath];
    
    return frame;
}

- (void)calculateItemLayoutAttributes
{
    // N.B. Assumes headers have already been calculated
    NSUInteger numberOfSections = self.collectionView.numberOfSections;
    
    CGRect itemFrame = CGRectZero;
    CGRect totalItemFrame = CGRectZero;
    
    for (NSUInteger section = 0; section < numberOfSections; section++)
    {
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        for (NSUInteger item = 0; item < numberOfItems; item++)
        {
            itemFrame = [self calculateFrameForCellAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]
                                                priorItemFrame:itemFrame];
            totalItemFrame = CGRectUnion(totalItemFrame, itemFrame);
        }
    }
    // If there are items, add on the last item and content insets and set the content frame
    if (!CGRectEqualToRect(totalItemFrame, CGRectZero))
    {
        [self resetPlaceholderAttributes];
        self.contentFrame = CGRectInset(totalItemFrame, 0.0, -(_itemInsets.bottom + _contentInsets.bottom));
    }
    else
    {
        // No items? Just make the content the two header frames
        [self calculatePlaceholderLayoutAttributes];
        self.contentFrame = CGRectUnion(CGRectUnion(_headerTitleViewAttributes.frame, _headerDetailViewAttributes.frame), _placeHolderViewAttributes.frame);
    }
}

- (void)resetPlaceholderAttributes
{
    // Reset the frame of the placeholder, effectively hiding it
    _placeHolderViewAttributes.frame = CGRectZero;
    [_allAttributes addObject:_placeHolderViewAttributes];
}

- (void)calculatePlaceholderLayoutAttributes
{
    // The header title view is always at the top of the content frame and is always the width of the content view
    _placeHolderViewAttributes.frame = CGRectMake(0.0, 0.0,
                                                  self.collectionView.bounds.size.width -
                                                  self.collectionView.contentInset.left -
                                                  self.collectionView.contentInset.right,
                                                  self.collectionView.bounds.size.height -
                                                  self.collectionView.contentInset.top -
                                                  self.collectionView.contentInset.bottom);
    [_allAttributes addObject:_placeHolderViewAttributes];
}

- (void)calculateHeaderTitleLayoutAttributes
{
    // The header title view is always at the top of the content frame and is always the width of the content view
    _headerTitleViewAttributes.frame = CGRectMake(0.0, 0.0, self.collectionView.bounds.size.width, _headerTitleViewHeight);
    [_allAttributes addObject:_headerTitleViewAttributes];
}

- (void)calculateHeaderDetailLayoutAttributes:(BOOL)shouldIncludeOffset
{
    // WARNING: This is called at every pixel change when the user scrolls so be careful how much work is done here
    CGFloat yOffset = MAX(_headerTitleViewHeight, (shouldIncludeOffset ? self.collectionView.bounds.origin.y + self.collectionView.contentInset.top : 0.0));
    _headerDetailViewAttributes.frame = CGRectMake(0.0, yOffset, self.collectionView.bounds.size.width, _headerDetailViewHeight);
}

- (void)storeFrame:(CGRect)frame forIndexPath:(NSIndexPath *)indexPath
{
    // Store the attributes in an accessible AND a fast place
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    [_cellAttributes setObject:attributes forKey:indexPath];
    [_allAttributes addObject:attributes];
}

@end
