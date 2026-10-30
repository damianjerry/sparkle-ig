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
static const NSTimeInterval kSPKHomeTabLongPressDuration = 0.5;
static const NSTimeInterval kSPKGalleryTabLongPressDuration = 0.65;
static const NSTimeInterval kSPKProfileMoreSettingsLongPressDuration = 0.5;
static NSInteger const kSPKProfileMoreShortcutMaxInstallAttempts = 6;
static NSString *const kSPKGalleryQuickAccessDisabledValue = @"none";

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

// Light confirmation tap fired when a tab-bar shortcut activates. The global
// UIImpactFeedbackGenerator hook (DisableHaptics.x) already respects
// general_disable_haptics, so this stays silent when the user disabled haptics.
static void SPKFireShortcutHaptic(void) {
    if (![SPKUtils getBoolPref:@"tools_shortcut_haptics"])
        return;
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [generator prepare];
    [generator impactOccurred];
}

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

static BOOL SPKIsProfileMoreButton(UIView *view) {
    return [view.accessibilityIdentifier isEqualToString:@"profile-more-button"];
}

static void SPKAddProfileSettingsLongPressToView(UIView *view) {
    return;
}

static void (*orig_spkProfileMoreDidMoveToWindow)(id, SEL);
static void SPKHookedProfileMoreDidMoveToWindow(id self, SEL _cmd) {
    if (orig_spkProfileMoreDidMoveToWindow)
        orig_spkProfileMoreDidMoveToWindow(self, _cmd);
}

static void (*orig_spkProfileMoreLayoutSubviews)(id, SEL);
static void SPKHookedProfileMoreLayoutSubviews(id self, SEL _cmd) {
    if (orig_spkProfileMoreLayoutSubviews)
        orig_spkProfileMoreLayoutSubviews(self, _cmd);
}

static BOOL SPKProfileMoreShortcutHooksInstalled = NO;
static BOOL SPKProfileMoreShortcutRetryScheduled = NO;
static NSInteger SPKProfileMoreShortcutInstallAttempts = 0;

static void SPKInstallProfileMoreShortcutHooks(void) {
    return;
}

static NSString *SPKGalleryShortcutTabIdentifier(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [defaults stringForKey:@"gallery_quick_access_tab"];
    if (identifier.length == 0) {
        identifier = kSPKGalleryQuickAccessDisabledValue;
    }
    if ([identifier isEqualToString:kSPKGalleryQuickAccessDisabledValue])
        return identifier;

    NSString *target = identifier;
    BOOL usesClassicTabOrdering = [[[NSUserDefaults standardUserDefaults] stringForKey:@"interface_nav_order"] isEqualToString:@"classic"];
    if (usesClassicTabOrdering && [target isEqualToString:@"direct-inbox-tab"])
        return @"camera-tab";
    if (!usesClassicTabOrdering && [target isEqualToString:@"camera-tab"])
        return @"direct-inbox-tab";
    return target;
}

static BOOL SPKTabButtonMatchesTarget(NSString *identifier, NSString *label, NSString *target) {
    if (target.length == 0 || [target isEqualToString:kSPKGalleryQuickAccessDisabledValue])
        return NO;

    NSString *candidate = [NSString stringWithFormat:@"%@ %@", identifier ?: @"", label ?: @""].lowercaseString;
    if ([identifier isEqualToString:target])
        return YES;
    if ([target isEqualToString:@"mainfeed-tab"] && ([candidate containsString:@"mainfeed"] || [candidate containsString:@"home"]))
        return YES;
    if ([target isEqualToString:@"reels-tab"] && ([candidate containsString:@"clips"] || [candidate containsString:@"reels"]))
        return YES;
    if ([target isEqualToString:@"camera-tab"] && [candidate containsString:@"create"])
        return YES;
    if ([target isEqualToString:@"explore-tab"] && ([candidate containsString:@"explore"] || [candidate containsString:@"search"]))
        return YES;
    if ([target isEqualToString:@"direct-inbox-tab"] && ([candidate containsString:@"direct"] ||
                                                         [candidate containsString:@"inbox"] ||
                                                         [candidate containsString:@"message"]))
        return YES;
    if ([target isEqualToString:@"profile-tab"] && ([candidate containsString:@"profile"] ||
                                                    [candidate containsString:@"tab_avatar"]))
        return YES;
    return NO;
}

static BOOL SPKIsMessagesOnlyMode(void) {
    return [SPKSingleVisibleTabIdentifierFromPreferences() isEqualToString:SPKTabIdentifierDirect];
}

static NSString *SPKSparkleTabIdentifierForAccessibilityIdentifier(NSString *identifier) {
    if ([identifier isEqualToString:@"mainfeed-tab"]) return SPKTabIdentifierFeed;
    if ([identifier isEqualToString:@"reels-tab"]) return SPKTabIdentifierClips;
    if ([identifier isEqualToString:@"direct-inbox-tab"]) return SPKTabIdentifierDirect;
    if ([identifier isEqualToString:@"camera-tab"]) return SPKTabIdentifierCreate;
    if ([identifier isEqualToString:@"explore-tab"]) return SPKTabIdentifierSearch;
    if ([identifier isEqualToString:@"profile-tab"]) return SPKTabIdentifierProfile;
    return nil;
}

static BOOL SPKTabHiddenForIdentifier(NSString *identifier) {
    BOOL usesClassic = [[SPKUtils getStringPref:@"interface_nav_order"] isEqualToString:@"classic"];

    // A hidden tab that Saved is borrowing still has its button on the bar, so
    // the shortcut stays on it instead of moving to the next tab along.
    NSString *sparkleIdentifier = SPKSparkleTabIdentifierForAccessibilityIdentifier(identifier);
    if (sparkleIdentifier && [sparkleIdentifier isEqualToString:SPKEffectiveSavedCarrier()])
        return NO;

    if ([identifier isEqualToString:@"mainfeed-tab"])
        return [SPKUtils getBoolPref:@"interface_hide_feed_tab"];
    if ([identifier isEqualToString:@"reels-tab"])
        return [SPKUtils getBoolPref:@"interface_hide_reels_tab"];
    if ([identifier isEqualToString:@"direct-inbox-tab"])
        return usesClassic || [SPKUtils getBoolPref:@"interface_hide_msgs_tab"];
    if ([identifier isEqualToString:@"camera-tab"])
        return !usesClassic || [SPKUtils getBoolPref:@"interface_hide_create_tab"];
    if ([identifier isEqualToString:@"explore-tab"])
        return [SPKUtils getBoolPref:@"interface_hide_explore_tab"];
    if ([identifier isEqualToString:@"profile-tab"])
        return [SPKUtils getBoolPref:@"interface_hide_profile_tab"];
    return NO;
}

static NSString *SPKResolvedSettingsShortcutTabIdentifier(void) {
    return nil;
}

static NSString *SPKResolvedGalleryShortcutTabIdentifier(void) {
    return nil;
}

static BOOL SPKTabIdentifierMatchesGalleryShortcut(NSString *identifier, NSString *label) {
    return NO;
}

static BOOL SPKShouldReplaceProfileTabLongPress(NSString *identifier, NSString *label) {
    return NO;
}

// Show Sparkle tweak settings by holding on the settings/more icon under profile for ~1 second
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
        SPKInstallProfileMoreShortcutHooks();
    });
}
