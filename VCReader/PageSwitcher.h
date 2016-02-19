//
//  PageSwitcher.h
//
//  Copyright (c) 2013 Pavel Malinnikov. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PageCache.h"

typedef enum
{
	kPageSwitcherDirectionBackward,
	kPageSwitcherDirectionForward
} PageSwitchDirection;

// protocol, which own animators must adopt
@protocol PageSwitchAnimator <NSObject>

- (CAAnimation*) animationForPageOut: (PageSwitchDirection) switchDirection;
- (CAAnimation*) animationForPageIn: (PageSwitchDirection) switchDirection;

@end

// page switcher component with page precation ability and variable page turn animations
@interface PageSwitcher : UIViewController

@property (nonatomic, retain) PageCache *pageCache;
@property (nonatomic, retain) id <PageSwitchAnimator> switchAnimator;

- (id)initWithPageClass: (Class) pageClass
	 pageSwitchAnimator: (id <PageSwitchAnimator>) animationProvider
	initialLogicalIndex: (uint) startIndex;

- (void) switchPage: (PageSwitchDirection) direction;

@end
