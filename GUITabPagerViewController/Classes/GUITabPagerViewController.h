//
//  GUITabPagerViewController.h
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GUITabPagerDataSource;
@protocol GUITabPagerDelegate;

@class GUITabScrollView, GUITabBarItemView;

@interface GUITabPagerViewController : UIViewController

@property (weak, nonatomic) id<GUITabPagerDataSource> dataSource;
@property (weak, nonatomic) id<GUITabPagerDelegate> delegate;

@property (strong, nonatomic) GUITabScrollView *header;
@property (strong, nonatomic) UIPageViewController *pageViewController;

- (void)reloadData;
- (void)reloadTabs;
- (NSInteger)selectedIndex;

- (void)selectTabbarIndex:(NSInteger)index;
- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation;

@end

@protocol GUITabPagerDataSource <NSObject>

@required
- (NSInteger)numberOfViewControllers;
- (UIViewController *)viewControllerForIndex:(NSInteger)index;

@optional
- (GUITabBarItemView *)viewForTabAtIndex:(NSInteger)index;
- (NSString *)titleForTabAtIndex:(NSInteger)index;
- (CGFloat)tabHeight;
- (UIColor *)tabColor;
- (UIColor *)tabBackgroundColor;
- (UIFont *)titleFont;
- (UIColor *)titleColor;
- (UIColor *)selectedTitleColor;

@end

@protocol GUITabPagerDelegate <NSObject>

@optional
- (void)tabPager:(GUITabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index;
- (void)tabPager:(GUITabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index;

@end
