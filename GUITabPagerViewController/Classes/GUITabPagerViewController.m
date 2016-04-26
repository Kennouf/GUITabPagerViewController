//
//  GUITabPagerViewController.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "GUITabPagerViewController.h"
#import "GUITabScrollView.h"
#import "GUITabBarItemView.h"

@interface GUITabPagerViewController () <GUITabScrollDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *tabTitles;
@property (strong, nonatomic) UIColor *headerColor;
@property (strong, nonatomic) UIColor *tabBackgroundColor;
@property (assign, nonatomic) CGFloat headerHeight;

@end

@implementation GUITabPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                              options:nil]];
    
    for (UIView *view in [[[self pageViewController] view] subviews]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setCanCancelContentTouches:YES];
            [(UIScrollView *)view setDelaysContentTouches:NO];
        }
    }
    
    [[self pageViewController] setDataSource:self];
    [[self pageViewController] setDelegate:self];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self reloadTabs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
    [[self header] animateToTabAtIndex:index];
    for (GUITabBarItemView *view in self.header.tabViews) {
        if ([self.header.tabViews indexOfObjectIdenticalTo:view] == index) {
            view.itemLabel.textColor = [self selectedColor];
        } else {
            view.itemLabel.textColor = [self color];
        }
    }
    if ([[self delegate] respondsToSelector:@selector(tabPager:willTransitionToTabAtIndex:)]) {
        [[self delegate] tabPager:self willTransitionToTabAtIndex:index];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    [self setSelectedIndex:[[self viewControllers] indexOfObject:[[self pageViewController] viewControllers][0]]];
    [[self header] animateToTabAtIndex:[self selectedIndex]];
    for (GUITabBarItemView *view in self.header.tabViews) {
        if ([self.header.tabViews indexOfObjectIdenticalTo:view] == [self selectedIndex]) {
            view.itemLabel.textColor = [self selectedColor];
        } else {
            view.itemLabel.textColor = [self color];
        }
    }
    if ([[self delegate] respondsToSelector:@selector(tabPager:didTransitionToTabAtIndex:)]) {
        [[self delegate] tabPager:self didTransitionToTabAtIndex:[self selectedIndex]];
    }
}

#pragma mark - Tab Scroll View Delegate

- (void)tabScrollView:(GUITabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index {
    if (index != [self selectedIndex]) {
        if ([[self delegate] respondsToSelector:@selector(tabPager:willTransitionToTabAtIndex:)]) {
            [[self delegate] tabPager:self willTransitionToTabAtIndex:index];
        }
        
        [[self pageViewController]  setViewControllers:@[[self viewControllers][index]]
                                             direction:(index > [self selectedIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                              animated:YES
                                            completion:^(BOOL finished) {
                                                [self setSelectedIndex:index];
                                                
                                                if ([[self delegate] respondsToSelector:@selector(tabPager:didTransitionToTabAtIndex:)]) {
                                                    [[self delegate] tabPager:self didTransitionToTabAtIndex:[self selectedIndex]];
                                                }
                                                [self reloadTabs];
                                            }];
    }
}

- (void)reloadData {
    [self setViewControllers:[NSMutableArray array]];
    [self setTabTitles:[NSMutableArray array]];
    
    for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
        UIViewController *viewController;
        
        if ((viewController = [[self dataSource] viewControllerForIndex:i]) != nil) {
            [[self viewControllers] addObject:viewController];
        }
        
        if ([[self dataSource] respondsToSelector:@selector(titleForTabAtIndex:)]) {
            NSString *title;
            if ((title = [[self dataSource] titleForTabAtIndex:i]) != nil) {
                [[self tabTitles] addObject:title];
            }
        }
    }
    
    [self reloadTabs];
    
    CGRect frame = [[self view] frame];
    frame.origin.y = [self headerHeight];
    frame.size.height -= [self headerHeight];
    
    [[[self pageViewController] view] setFrame:frame];
    
    [self.pageViewController setViewControllers:@[[self viewControllers][0]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:NO
                                     completion:nil];
    [self setSelectedIndex:0];
}

- (void)reloadTabs {
    if ([[self dataSource] numberOfViewControllers] == 0)
        return;
    
    if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
        [self setHeaderHeight:[[self dataSource] tabHeight]];
    } else {
        [self setHeaderHeight:44.0f];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabColor)]) {
        [self setHeaderColor:[[self dataSource] tabColor]];
    } else {
        [self setHeaderColor:[UIColor orangeColor]];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBackgroundColor)]) {
        [self setTabBackgroundColor:[[self dataSource] tabBackgroundColor]];
    } else {
        [self setTabBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    }
    
    NSMutableArray *tabViews = [NSMutableArray array];
    
    if ([[self dataSource] respondsToSelector:@selector(viewForTabAtIndex:)]) {
        for (int i = 0; i < [[self viewControllers] count]; i++) {
            UIView *view;
            if ((view = [[self dataSource] viewForTabAtIndex:i]) != nil) {
                [tabViews addObject:view];
            }
        }
    } else {
        UIFont *font;
        if ([[self dataSource] respondsToSelector:@selector(titleFont)]) {
            font = [[self dataSource] titleFont];
        } else {
            font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
        }
        
        UIColor *color = [self color];
        UIColor *selectedColor = [self selectedColor];
        
        for (int i = 0; i < [self tabTitles].count; i++) {
            NSString *title = [[self tabTitles] objectAtIndex:i];
            UILabel *label = [UILabel new];
            [label setText:title];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:font];
            if (i == self.selectedIndex) {
                [label setTextColor:selectedColor];
            } else {
                [label setTextColor:color];
            }
            [label sizeToFit];
            
            CGRect frame = [label frame];
            frame.size.width = MAX(frame.size.width + 20, 85);
            [label setFrame:frame];
            [tabViews addObject:label];
        }
    }
    
    if ([self header]) {
        [[self header] removeFromSuperview];
    }
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = [self headerHeight];
    [self setHeader:[[GUITabScrollView alloc] initWithFrame:frame tabViews:tabViews tabBarHeight:[self headerHeight] tabColor:[self headerColor] backgroundColor:[self tabBackgroundColor] selectedTabIndex:self.selectedIndex]];
    [[self header] setTabScrollDelegate:self];
    
    [[self view] addSubview:[self header]];
}

- (UIColor *)color
{
    if ([[self dataSource] respondsToSelector:@selector(titleColor)]) {
        return [[self dataSource] titleColor];
    } else {
        return [UIColor blackColor];
    }
}

- (UIColor *)selectedColor
{
    if ([[self dataSource] respondsToSelector:@selector(selectedTitleColor)]) {
        return [[self dataSource] selectedTitleColor];
    } else {
        return [self color];
    }
}

#pragma mark - Public Methods

- (void)selectTabbarIndex:(NSInteger)index {
    [self selectTabbarIndex:index animation:NO];
}

- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation {
    [self.pageViewController setViewControllers:@[[self viewControllers][index]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:animation
                                     completion:nil];
    [[self header] animateToTabAtIndex:index animated:animation];
    [self setSelectedIndex:index];
}

@end
