//
//  BMLViewController.m
//  LayoutDemo
//
//  Created by Adam Iredale on 26/03/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import "BMLViewController.h"

#pragma mark - Pods

#import <BMFloatingHeaderCollectionViewLayout/BMFloatingHeaderCollectionViewLayout.h>
#import <BMFloatingHeaderCollectionViewLayout/BMReusableContainerView.h>
#import <SSDataSources/SSArrayDataSource.h>

static NSString *const kDemoTitle   = @"HEADER TEXT CAN GO HERE\n(or any other UIView subclass)";
static NSString *const kDemoDetail  = @"Data Empty";
static NSString *const kDemoEmpty   = @"Your empty view here!";
static NSString *const kDemoData    = @"The title area goes away but the detail never does. Cool, huh? ... All " \
                                      @"orientations are handled automatically and there's even empty view management built in!";

@interface BMLViewController () <BMFloatingHeaderCollectionViewLayoutDelegate>
/**
 *  Demo datasource
 */
@property (nonatomic, strong) SSArrayDataSource *dataSource;

@property (nonatomic, strong) UISegmentedControl *detailControl;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation BMLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    self.titleLabel =
    ({
        UILabel *label      = [[UILabel alloc] init];
        label.text          = kDemoTitle;
        label.numberOfLines = 2;
        label;
    });
    
    self.detailControl =
    ({
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[kDemoDetail componentsSeparatedByString:@" "]];
        [control addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
        control.selectedSegmentIndex = 0;
        control;
    });

    self.emptyLabel =
    ({
        UILabel *label      = [[UILabel alloc] init];
        label.text          = kDemoEmpty;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    self.dataSource = [[SSArrayDataSource alloc] initWithItems:[kDemoData componentsSeparatedByString:@" "]];
    
    _dataSource.cellCreationBlock = ^(id object,
                                      UICollectionView *collectionView,
                                      NSIndexPath *indexPath)
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    };
    
    _dataSource.cellConfigureBlock = ^(UICollectionViewCell *cell,
                                       NSString *object,
                                       UICollectionView *collectionView,
                                       NSIndexPath *indexPath)
    {
        // Ordinarily you'd make your own collection view cell subclass
        // This is just lazy demo code
        UILabel *label = cell.contentView.subviews.firstObject;
        if (!label)
        {
            label = [[UILabel alloc] init];
        }
        label.text = object;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        label.frame = cell.contentView.bounds;
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    };
    
    __weak __block typeof(self) weakSelf = self;
    
    _dataSource.collectionSupplementaryCreationBlock = ^(NSString *kind,
                                                         UICollectionView *cv,
                                                         NSIndexPath *indexPath)
    {
        BMReusableContainerView *view = [cv dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
        return view;
    };
    
    _dataSource.collectionSupplementaryConfigureBlock = ^(BMReusableContainerView *view,
                                                          NSString *kind,
                                                          UICollectionView *cv,
                                                          NSIndexPath *indexPath)
    {
        if ([kind isEqualToString:BMFloatingHeaderCollectionViewLayoutHeaderTitleKind])
        {
            // Your header title view here
            view.embeddedView = weakSelf.titleLabel;
        }
        else if ([kind isEqualToString:BMFloatingHeaderCollectionViewLayoutHeaderDetailKind])
        {
            // Your header detail view here
            view.embeddedView = weakSelf.detailControl;
        }
        else if ([kind isEqualToString:BMFloatingHeaderCollectionViewLayoutPlaceholderKind])
        {
            // Your empty view here
            view.embeddedView = weakSelf.emptyLabel;
        }
    };
    
    BMFloatingHeaderCollectionViewLayout *layout = (id)self.collectionView.collectionViewLayout;
    
    layout.headerTitleViewHeight    = 60;
    layout.headerDetailViewHeight   = 40;
    layout.itemInsets               = UIEdgeInsetsMake(2, 2, 2, 2);

    _dataSource.collectionView = self.collectionView;
    
    [_dataSource reloadData];
    
}

#pragma mark - BMFloatingHeaderCollectionViewLayoutDelegate

- (CGFloat)collectionViewLayout:(BMFloatingHeaderCollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Here you could calculate dynamic heights from data if required (I do)
    return 40.0;
}

#pragma mark - Actions

- (void)segmentDidChange:(UISegmentedControl *)sender
{
    if (!sender.selectedSegmentIndex)
    {
        [self.dataSource appendItems:[kDemoData componentsSeparatedByString:@" "]];
    }
    else
    {
        [self.dataSource clearItems];
    }
}

@end
