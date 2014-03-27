//
//  BMReusableContainerView.h
//  Pods
//
//  Created by Adam Iredale on 28/03/2014.
//
//

#import <UIKit/UIKit.h>

/**
 *  A container view that will embed any other kind of UIView-based class that it is given,
 *  freeing developers of having to use UICollectionReusableView as a base class for supplementary
 *  and decoration views
 */

@interface BMReusableContainerView : UICollectionReusableView
/**
 *  UIView object embedded and automatically resized to fit the container
 */
@property (nonatomic, strong) UIView *embeddedView;

@end
