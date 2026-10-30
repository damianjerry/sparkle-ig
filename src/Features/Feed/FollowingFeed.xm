// Following feed mode, adapted from InstaSane by Edoardo (@n3d1117).
// https://github.com/n3d1117/InstaSane

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <substrate.h>

#import "../../Utils.h"

// IGHomeFeedPickerMenuItem enum value (stable across 410→453).
static NSInteger const IGHomeFeedPickerMenuItemFollowing = 5;

static BOOL SPKFollowingFeedEnabled(void) {
    return YES;
}

%group SPKFollowingPickerHooks

%hook IGHomeFeedPickerMenuController

- (id)initWithUserSession:(id)userSession
                     menuItems:(NSArray *)menuItems
             homeFeedViewModel:(id)homeViewModel
               analyticsModule:(id)analyticsModule
          navigationController:(id)navigationController
    isForYouContentLaneEnabled:(BOOL)forYouEnabled {
    if (!SPKFollowingFeedEnabled() || ![menuItems isKindOfClass:[NSArray class]])
        return %orig;
    NSMutableArray *items = menuItems.mutableCopy;
    [items removeObject:@(IGHomeFeedPickerMenuItemFollowing)];
    [items insertObject:@(IGHomeFeedPickerMenuItemFollowing) atIndex:0];
    return %orig(userSession, items, homeViewModel, analyticsModule, navigationController, NO);
}

%end

%hook IGHomeFeedPickerHelpers

+ (BOOL)homeFeedPickerShouldShowFollowingFeed:(id)session {
    return YES;
}

+ (BOOL)homeFeedPickerShouldShowFollowingFeedAsLatest:(id)session {
    return YES;
}

+ (BOOL)homeFeedPickerShouldShowForYouFeed:(id)session {
    return NO;
}

+ (BOOL)homeFeedPickerShouldShowSundialForYouFeed:(id)session {
    return NO;
}

+ (BOOL)homeFeedPickerShouldShowFriendsLane:(id)a1 navConfiguration:(id)a2 {
    return NO;
}

+ (BOOL)homeFeedPickerShouldShowNearbyLane:(id)a1 navConfiguration:(id)a2 sundialCaliforniaGatingManager:(id)a3 {
    return NO;
}

+ (BOOL)homeFeedPickerShouldShowCarrera:(id)a1 navConfiguration:(id)a2 {
    return NO;
}

%end

%end // SPKFollowingPickerHooks

%group SPKFollowingDSAHooks

%hook IGDSAGatingManager

// Persisted "preferred content lane" (EU DSA): returning 1 = Following.
- (NSInteger)feedStickyContentLaneSelection {
    if (!SPKFollowingFeedEnabled())
        return %orig;
    return 1;
}

%end

%end // SPKFollowingDSAHooks

%group SPKFollowingStoryTrayHooks

%hook IGStoryTrayCellViewModel

- (double)avatarSizeAdjustment {
    if (SPKFollowingFeedEnabled()) {
        @try {
            if ([self respondsToSelector:@selector(module)]) {
                NSString *module = ((NSString * (*)(id, SEL)) objc_msgSend)(self, @selector(module));
                if ([module isKindOfClass:[NSString class]] && [module hasPrefix:@"feed_timeline"]) {
                    return 28.5;
                }
            }
        } @catch (__unused NSException *e) {}
    }
    return %orig;
}

%end

%end // SPKFollowingStoryTrayHooks

%group SPKFollowingContainerHooks

%hook IGHomeSundialFeedContentContainerViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (SPKFollowingFeedEnabled()) {
        if ([self respondsToSelector:@selector(navigateToFollowingFeedWithAnimated:)]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(self, @selector(navigateToFollowingFeedWithAnimated:), NO);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (SPKFollowingFeedEnabled()) {
        if ([self respondsToSelector:@selector(navigateToFollowingFeedWithAnimated:)]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(self, @selector(navigateToFollowingFeedWithAnimated:), NO);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self respondsToSelector:@selector(navigateToFollowingFeedWithAnimated:)]) {
                ((void (*)(id, SEL, BOOL))objc_msgSend)(self, @selector(navigateToFollowingFeedWithAnimated:), NO);
            }
        });
    }
}

- (void)selectDefaultTabAndScrollToTop {
    if (SPKFollowingFeedEnabled()) {
        if ([self respondsToSelector:@selector(navigateToFollowingFeedWithAnimated:)]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(self, @selector(navigateToFollowingFeedWithAnimated:), NO);
            return;
        }
    }
    %orig;
}

%end

%end // SPKFollowingContainerHooks

extern "C" void SPKInstallFollowingFeedHooksIfEnabled(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class picker = SPKResolveIGClass(@"IGHomeFeedPicker.IGHomeFeedPickerMenuController", @"IGHomeFeedPickerMenuController");
        Class helpers = SPKResolveIGClass(@"IGHomeFeedPicker.IGHomeFeedPickerHelpers", @"IGHomeFeedPickerHelpers");
        Class dsa = SPKResolveIGClass(@"IGDSAShared.IGDSAGatingManager", @"IGDSAGatingManager");
        Class tray = SPKResolveIGClass(@"IGStoryTrayUIModels.IGStoryTrayCellViewModel", @"IGStoryTrayCellViewModel");
        Class container = SPKResolveIGClass(@"IGHomeSundialFeedContentContainer.IGHomeSundialFeedContentContainerViewController",
                                           @"_TtC33IGHomeSundialFeedContentContainer47IGHomeSundialFeedContentContainerViewController");

        SPKLog(@"FollowingFeed", @"installing hooks — picker=%@ helpers=%@ dsa=%@ tray=%@ container=%@",
               picker ? @"OK" : @"NIL", helpers ? @"OK" : @"NIL", dsa ? @"OK" : @"NIL",
               tray ? @"OK" : @"NIL", container ? @"OK" : @"NIL");

        if (picker || helpers) {
            %init(SPKFollowingPickerHooks,
                  IGHomeFeedPickerMenuController = picker,
                  IGHomeFeedPickerHelpers = helpers);
        }

        if (dsa) {
            %init(SPKFollowingDSAHooks,
                  IGDSAGatingManager = dsa);
        }

        if (tray) {
            %init(SPKFollowingStoryTrayHooks,
                  IGStoryTrayCellViewModel = tray);
        }

        if (container) {
            %init(SPKFollowingContainerHooks,
                  IGHomeSundialFeedContentContainerViewController = container);
        }
    });
}
