//
//  PageCache.m
//
//  Copyright (c) 2013 Pavel Malinnikov. All rights reserved.
//

#import "PageCache.h"

@implementation PageCache

- (id)initWithPageClass: (Class) pageClass initialLogicalIndex: (uint) startIndex
{
    self = [super init];
	
    if (self)
	{
		// let's see, if the pageClass is suitible for instantiating pages
		BOOL isPageClassValid = [pageClass isSubclassOfClass:[UIViewController class]]
		&& [pageClass conformsToProtocol:@protocol(CacheablePageViewController)];
		
        if (!isPageClassValid)
		{
			[NSException raise:NSInvalidArgumentException
						format:@"%@ is not subclass of UIViewController or not conforms to %@ protocol",
			 NSStringFromClass(pageClass), NSStringFromProtocol(@protocol(CacheablePageViewController))];
			
			return nil;
		}
		
		_pageClass = pageClass;
		self.currentLogicalIndex = startIndex;
		
        // it is a minimal recommended cache size, because UIPageViewController can produce unfinished
        // forward page turn and immediate turn in opposite direction
		_backwardCacheSize = 2;
		_forwardCacheSize = 2;
		
		// initial filling cache with pages
		_cachedPages = [[NSMutableArray alloc] init];
		
		// initial page
		CacheablePage *aPage = [self createPageForIndex: self.currentLogicalIndex];
		
		if (aPage != nil)
		{
			aPage.view.hidden = NO;
			self.currentPage = aPage;
			[_cachedPages addObject: aPage];
			
			// backward
			for (uint i = 0; i < _backwardCacheSize; i++)
			{
				int offset = i + 1;
				CacheablePage *aPage = [self createPageForIndex: self.currentLogicalIndex - offset];
				
				// if no page create, no need to cache further
				if (aPage == nil)
					break;
				
				// put a page at the beginning of cache array
				[_cachedPages insertObject: aPage atIndex: 0];
			}
			
			// forward
			for (uint i = 0; i < _forwardCacheSize; i++)
			{
				int offset = i + 1;
				CacheablePage *aPage = [self createPageForIndex: self.currentLogicalIndex + offset];
				
				if (aPage == nil)
					break;
				
				// put a page at the end of cache array
				[_cachedPages addObject: aPage];
			}
		}
    }
	
    return self;
}

- (CacheablePage *) createPageForIndex: (int) index
{
	CacheablePage *resultViewController = [[_pageClass alloc] init];
	
	// make some access to view to load the view hierarchy
	resultViewController.view.hidden = YES;
	
	if (![resultViewController prepareToShowAtLogicalIndex: index])
	{
		return nil;
	}
	
	resultViewController.logicalIndex = index;
	
	NSLog(@"createPage %d %@", index, resultViewController);
	return resultViewController;
}

- (CacheablePage *) viewControllerBeforeViewController:(UIViewController *)viewController
{
	NSUInteger currentPageCacheIndex = [_cachedPages indexOfObject:viewController];
	
	// additional safety for non-properly use
	if (currentPageCacheIndex == NSNotFound)
		return nil;
	
	int nextPageCacheIndex = (int)currentPageCacheIndex - 1;
	CacheablePage *nextViewController = nil;
	
	// is there a precached page?
	if (nextPageCacheIndex >= 0 && nextPageCacheIndex < [_cachedPages count])
	{
		nextViewController = (CacheablePage *) [_cachedPages objectAtIndex: nextPageCacheIndex];
		nextViewController.view.hidden = NO;
		self.currentPage = nextViewController;
		self.currentLogicalIndex = nextViewController.logicalIndex;
		
		NSLog(@"< %@", self.currentPage);
		
		// nextViewController become current page, so shift cache range to it
		for (uint i = 0; i < _backwardCacheSize; i++)
		{
			int offset = i + 1;
			// is there something in cache already?
			int testedCacheIndex = nextPageCacheIndex - offset;
			
			// don't recreate page if exists
			if (testedCacheIndex >= 0 && testedCacheIndex < [_cachedPages count])
				continue;
			
			// we are beyond the cache range, extend it to desired side
			CacheablePage *aPage = [self createPageForIndex: self.currentLogicalIndex - offset];
			
			// if no page create, no need to cache further
			if (aPage == nil)
				break;
			
			NSLog(@"<< %@", aPage);
			// push a page at the beginning of cache array
			[_cachedPages insertObject: aPage atIndex: 0];
			
			// and pop a page from another side
			if ([_cachedPages count] > _backwardCacheSize + 1 + _forwardCacheSize)
				[_cachedPages removeLastObject];
		}
	}
	
	return nextViewController;
}

- (CacheablePage *) viewControllerAfterViewController:(UIViewController *)viewController
{
	NSUInteger currentPageCacheIndex = [_cachedPages indexOfObject:viewController];
	
	// additional safety for non-properly use
	if (currentPageCacheIndex == NSNotFound)
		return nil;
	
	int nextPageCacheIndex = (int)currentPageCacheIndex + 1;
	CacheablePage *nextViewController = nil;
	
	// is there a precached page?
	if (nextPageCacheIndex >= 0 && nextPageCacheIndex < [_cachedPages count])
	{
		nextViewController = (CacheablePage *) [_cachedPages objectAtIndex: nextPageCacheIndex];
		nextViewController.view.hidden = NO;
		self.currentPage = nextViewController;
		self.currentLogicalIndex = nextViewController.logicalIndex;
		
		NSLog(@"> %@", self.currentPage);
		
		// nextViewController become current page, so shift cache range to it
		for (uint i = 0; i < _forwardCacheSize; i++)
		{
			int offset = i + 1;
			// is there something in cache already?
			int testedCacheIndex = nextPageCacheIndex + offset;
			
			// don't recreate page if exists
			if (testedCacheIndex >= 0 && testedCacheIndex < [_cachedPages count])
				continue;
			
			// we are beyond the cache range, extend it to desired side
			CacheablePage *aPage = [self createPageForIndex: self.currentLogicalIndex + offset];
			
			// if no page create, no need to try to cache further
			if (aPage == nil)
				break;
			
			NSLog(@">> %@", aPage);
			// push a page at the end of cache array
			[_cachedPages addObject:aPage];
			
			// and pop a page from another side
			if ([_cachedPages count] > _backwardCacheSize + 1 + _forwardCacheSize)
				[_cachedPages removeObjectAtIndex:0];
			
		}
	}
	
	return nextViewController;
}


#pragma mark - UIPageViewControllerDataSource protocol

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController
{
	return [self viewControllerBeforeViewController:viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController
{
	return [self viewControllerAfterViewController:viewController];
}

@end
