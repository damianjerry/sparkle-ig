#import <objc/runtime.h>
#import <substrate.h>

#import "../../InstagramHeaders.h"
#import "../../Settings/SPKSettingsViewController.h"
#import "../../Shared/Gallery/SPKGalleryViewController.h"
#import "../../Utils.h"
#import "../../App/SPKPerfMeter.h"
#import "../../Shared/Navigation/SPKTabConfiguration.h"

static const void *kSPKHomeTabSettingsLongPressAssocKey = &kSPKHomeTabSettingsLongPressAssocKey;
static const void *kSPKGalleryTabLongPressAssocKey = &kSPKGalleryTabLongPressAssocKey;
static const void *kSPKProfileMoreSettingsLongPressAssocKey = &kSPKProfileMoreSettingsLongPressAssocKey;

@interface IGTabBarButton (SPKQuickActions)
- (void)spk_addLongPressWithAction:(SEL)action marker:(const void *)marker minimumDuration:(NSTimeInterval)minimumDuration;
- (void)spk_removeProfileAccountPickerLongPressIfNeeded;
- (void)spk_removeGalleryLongPressIfNeeded;
- (void)spk_removeSettingsLongPressIfNeeded;
- (void)handleHomeTabLongPress:(UILongPressGestureRecognizer *)sender;
- (void)handleDirectInboxTabLongPress:(UILongPressGestureRecognizer *)sender;
@end

@interface SPKSettingsShortcutTarget : NSObject
+ (instancetype)sharedTarget;
- (void)handleProfileMoreLongPress:(UILongPressGestureRecognizer *)sender;
@end

@implementation SPKSettingsShortcutTarget
+ (instancetype)sharedTarget {
    static SPKSettingsShortcutTarget *target;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        target = [SPKSettingsShortcutTarget new];
    });
    return target;
}

- (void)handleProfileMoreLongPress:(UILongPressGestureRecognizer *)sender {
    return;
}
@end

%group SPKSettingsShortcutsHooks

// Tab bar button hook: disables settings shortcuts and locks profile tab from opening account switcher
%hook IGTabBarButton

- (void)setAccessibilityIdentifier:(NSString *)identifier {
    %orig;
    [self setNeedsLayout];
}

- (void)setAccessibilityLabel:(NSString *)label {
    %orig;
    [self setNeedsLayout];
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    NSString *identifier = self.accessibilityIdentifier ?: @"";
    NSString *label = self.accessibilityLabel ?: @"";
    BOOL isProfileTab = [identifier isEqualToString:@"profile-tab"] ||
                        [identifier containsString:@"profile"] ||
                        [label.lowercaseString containsString:@"profile"] ||
                        [identifier containsString:@"tab_avatar"];

    // Single Account Lock: Block Instagram from attaching account switcher long press to profile tab
    if (isProfileTab && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return;
    }

    // Block any tweak settings or gallery shortcut gestures
    if (objc_getAssociatedObject(gestureRecognizer, kSPKHomeTabSettingsLongPressAssocKey) ||
        objc_getAssociatedObject(gestureRecognizer, kSPKProfileMoreSettingsLongPressAssocKey) ||
        objc_getAssociatedObject(gestureRecognizer, kSPKGalleryTabLongPressAssocKey)) {
        return;
    }

    %orig;
}

- (void)layoutSubviews {
    %orig;
    SPK_PERF_SCOPE(@"SettingsShortcuts.layoutSubviews");

    // Remove any tweak shortcuts
    [self spk_removeSettingsLongPressIfNeeded];
    [self spk_removeGalleryLongPressIfNeeded];

    // Single Account Lock: Remove profile account switcher long press if attached
    NSString *identifier = self.accessibilityIdentifier ?: @"";
    NSString *label = self.accessibilityLabel ?: @"";
    BOOL isProfileTab = [identifier isEqualToString:@"profile-tab"] ||
                        [identifier containsString:@"profile"] ||
                        [label.lowercaseString containsString:@"profile"] ||
                        [identifier containsString:@"tab_avatar"];
    if (isProfileTab) {
        for (UIGestureRecognizer *g in [self.gestureRecognizers copy]) {
            if ([g isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [self removeGestureRecognizer:g];
            }
        }
    }
}

%new - (void)spk_addLongPressWithAction:(SEL)action marker:(const void *)marker minimumDuration:(NSTimeInterval)minimumDuration {
    return;
}

%new - (void)spk_removeProfileAccountPickerLongPressIfNeeded {
    for (UIGestureRecognizer *gesture in [self.gestureRecognizers copy]) {
        if (![gesture isKindOfClass:[UILongPressGestureRecognizer class]])
            continue;
        [self removeGestureRecognizer:gesture];
    }
}

%new - (void)spk_removeGalleryLongPressIfNeeded {
    for (UIGestureRecognizer *gesture in [self.gestureRecognizers copy]) {
        if (![gesture isKindOfClass:[UILongPressGestureRecognizer class]])
            continue;
        if (objc_getAssociatedObject(gesture, kSPKGalleryTabLongPressAssocKey)) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

%new - (void)spk_removeSettingsLongPressIfNeeded {
    for (UIGestureRecognizer *gesture in [self.gestureRecognizers copy]) {
        if (![gesture isKindOfClass:[UILongPressGestureRecognizer class]])
            continue;
        if (objc_getAssociatedObject(gesture, kSPKHomeTabSettingsLongPressAssocKey)) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

%new - (void)handleHomeTabLongPress:(UILongPressGestureRecognizer *)sender {
    return;
}

%new - (void)handleDirectInboxTabLongPress:(UILongPressGestureRecognizer *)sender {
    return;
}
%end

%hook IGDirectInboxNavigationHeaderView
- (void)layoutSubviews {
    %orig;
    SPK_PERF_SCOPE(@"SettingsShortcuts.layoutSubviews2");

    UIButton *btn = nil;
    if ([self respondsToSelector:@selector(messageButton)]) {
        btn = [self valueForKey:@"messageButton"];
    }
    if (btn) {
        for (UIGestureRecognizer *gesture in [btn.gestureRecognizers copy]) {
            if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]] &&
                objc_getAssociatedObject(gesture, kSPKProfileMoreSettingsLongPressAssocKey)) {
                [btn removeGestureRecognizer:gesture];
            }
        }
    }
}
%end

%end

void SPKInstallSettingsShortcutsHooksIfNeeded(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        %init(SPKSettingsShortcutsHooks,
              IGDirectInboxNavigationHeaderView = SPKResolveIGClass(@"IGDirectInboxNavigationHeaderView.IGDirectInboxNavigationHeaderView",
                                                                    @"IGDirectInboxNavigationHeaderView"));
    });
}
