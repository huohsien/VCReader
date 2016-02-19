//
//  PageSwitcher.m
//
//  Copyright (c) 2013 Pavel Malinnikov. All rights reserved.
//

#import "PageSwitcher.h"


@implementation PageSwitcher

// PageSwitcher sould be created with page class and animator specified, so prevent from this initalizier
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        // encourage using initWithPageClass
		[NSException raise:NSInternalInconsistencyException
					format:@"You must create %@ with initWithPageClass instead of %@",
		 NSStringFromClass([self class]),
		 NSStringFromSelector(_cmd)];
    }
    return self;
}

// suitable initializier
- (id)initWithPageClass: (Class) pageClass
	 pageSwitchAnimator: (id <PageSwitchAnimator>) animator
	initialLogicalIndex: (uint) startIndex;
{
    self = [super initWithNibName:nil bundle:nil];
	
    if (self)
	{
		self.pageCache = [[PageCache alloc] initWithPageClass:pageClass
										   initialLogicalIndex:0];
		
		self.switchAnimator = animator;
	}
	
	return self;
}

- (void)dealloc
{
    self.pageCache = nil;
	self.switchAnimator = nil;
	
}

// view init
- (void)loadView
{
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	// add initial view controller
	CacheablePage *initialPage = self.pageCache.currentPage;
	
	if (initialPage && [initialPage parentViewController] != self)
	{
		[initialPage willMoveToParentViewController:self];
		
		[self addChildViewController: initialPage];
		
		initialPage.view.frame = self.view.bounds;
		initialPage.view.autoresizingMask = self.view.autoresizingMask;
		[self.view addSubview: initialPage.view];
		
		[initialPage didMoveToParentViewController:self];
		
		// add gesture support
		UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
											   initWithTarget:self
											   action:@selector(swipeLeft:)];
		swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
		[self.view addGestureRecognizer:swipeLeft];
		
		UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
												initWithTarget:self
												action:@selector(swipeRight:)];
		swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
		[self.view addGestureRecognizer:swipeRight];
	}
	
}


// transition for changind from one page to another
- (void)transitionFromViewController:(CacheablePage *) fromViewController
					toViewController:(CacheablePage *) toViewController
						   direction:(PageSwitchDirection) direction
{
	if (fromViewController == toViewController)
	{
		return;
	}
	
	// prepare view frame
	toViewController.view.frame = self.view.bounds;
	toViewController.view.autoresizingMask = self.view.autoresizingMask;
	
	// notify page about moving to new comtainer
	[fromViewController willMoveToParentViewController:nil];
	
	// lock user interaction till transition will finish
	self.view.userInteractionEnabled = NO;
	
	
	// getting in and out animations from animator
	CAAnimation *outAnimation = [self.switchAnimator animationForPageOut:direction];
	CAAnimation *inAnimation = [self.switchAnimator animationForPageIn:direction];
	
	
	// playing current page out
	[UIView transitionWithView:fromViewController.view
					  duration:outAnimation.duration
					   options:UIViewAnimationOptionTransitionNone
					animations:^{
						
						// page will dissolve with animation provided
						[[fromViewController.view layer] addAnimation:outAnimation forKey:@"outAnimation"];
						fromViewController.view.alpha = 0;
						
					}
					completion:^(BOOL finished) {
						
						// after out animation complete, remove current page
						[fromViewController.view removeFromSuperview];
						[fromViewController removeFromParentViewController];
						
						// new page initially transparent
						toViewController.view.alpha = 0;
						
						// adding new page
						[self addChildViewController:toViewController];
						[self.view addSubview:toViewController.view];
						
						// and make it opaque with inAnimation
						[UIView transitionWithView:toViewController.view
										  duration:inAnimation.duration
										   options:UIViewAnimationOptionTransitionNone
										animations:^{
											
											[[toViewController.view layer] addAnimation:inAnimation forKey:@"inAnimation"];
											toViewController.view.alpha = 1;
											
										}
										completion:^(BOOL finished) {
											
											// notify new page about it moved to new container
											[toViewController didMoveToParentViewController:self];
											
											// turn the user interaction on
											self.view.userInteractionEnabled = YES;
											
										}]; // inAnimation
						
						
					}]; // outAnimation
	
}


#pragma mark - gesture handlers

- (void)swipeLeft:(UISwipeGestureRecognizer *)gesture
{
	[self switchPage:kPageSwitcherDirectionForward];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)gesture
{
	[self switchPage:kPageSwitcherDirectionBackward];
}

#pragma mark - page switching

- (void) switchPage: (PageSwitchDirection) direction
{
	// take the current page
	CacheablePage *fromPage = self.pageCache.currentPage;
	
	CacheablePage *toPage = nil;
	
	// request the next page from datasource considering direction
	if (direction == kPageSwitcherDirectionBackward)
		toPage = [self.pageCache viewControllerBeforeViewController: fromPage];
	
	if (direction == kPageSwitcherDirectionForward)
		toPage = [self.pageCache viewControllerAfterViewController: fromPage];
	
	// if there is a page, playing animated transition from current page to new
	if (toPage)
		[self transitionFromViewController:fromPage toViewController:toPage direction: direction];
}



@end
