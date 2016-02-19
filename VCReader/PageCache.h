//
//  PageCache.h
//
//  Copyright (c) 2013 Pavel Malinnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

// all view controllers must adopt this protocol
@protocol CacheablePageViewController <NSObject>

@property (nonatomic, assign) int logicalIndex;
- (BOOL) prepareToShowAtLogicalIndex:(int)index;

@end


// more shorter typedef
typedef UIViewController <CacheablePageViewController> CacheablePage;


/**
 * Datasource for page switcher also able to used with UIPageViewController
 */
@interface PageCache : NSObject <UIPageViewControllerDataSource>
{
	Class _pageClass;
	NSMutableArray *_cachedPages;
	uint _backwardCacheSize;
	uint _forwardCacheSize;
}

@property (nonatomic, assign) CacheablePage *currentPage;
@property (nonatomic, assign) int currentLogicalIndex;

- (id)initWithPageClass: (Class) pageClass initialLogicalIndex: (uint) startIndex;

#pragma mark - UIPageViewControllerDataSource protocol

- (CacheablePage *) viewControllerBeforeViewController:(UIViewController *)viewController;
- (CacheablePage *) viewControllerAfterViewController:(UIViewController *)viewController;

@end
