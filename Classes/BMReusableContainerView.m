//
//  BMReusableContainerView.m
//  Pods
//
//  Created by Adam Iredale on 28/03/2014.
//
//

#import "BMReusableContainerView.h"

@implementation BMReusableContainerView

#pragma mark - Accessors

- (void)setEmbeddedView:(UIView *)embeddedView
{
    [_embeddedView removeFromSuperview];
    _embeddedView = embeddedView;
    if (_embeddedView)
    {
        [_embeddedView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:_embeddedView];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[emb]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"emb":_embeddedView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[emb]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"emb":_embeddedView}]];
        [self setNeedsUpdateConstraints];
    }
}

@end
