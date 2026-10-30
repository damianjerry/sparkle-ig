#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../../InstagramHeaders.h"
#import "../../Utils.h"

// Forward declarations for hooked classes to ensure clean compilation
@interface IGProfileTitleViewController : NSObject
- (void)_onTitleLabelTapped:(id)sender;
- (void)_onMultipleAccountsTapped:(id)sender;
- (void)_toggleSwitchUsersControl;
- (void)_displaySwitchUsersTableView:(BOOL)animated animated:(BOOL)arg2 completion:(id)completion;
- (void)_displaySwitchUsersTableView:(BOOL)animated animated:(BOOL)arg2 transitionDuration:(double)duration completion:(id)completion;
- (id)generateTitleViewWithRightBarButtonItems:(id)right leftBarButtonItems:(id)left user:(id)user;
@end

@interface IGAccountSwitcher (SPKLock)
- (long long)switchToUserWithPK:(id)pk destinationAppSurface:(id)surface destinationURL:(id)url entryPoint:(long long)point loggingData:(id)data;
- (long long)switchToUser:(id)user destinationAppSurface:(id)surface destinationURL:(id)url entryPoint:(long long)point loggingData:(id)data;
- (void)showLogoutAlertDialogWithUserSession:(id)session entryPoint:(NSInteger)point;
- (void)logOutFromSwitcherWithUserSession:(id)session entryPoint:(NSInteger)point;
@end

@interface IGAddAccountManager : NSObject
- (void)presentAddAccountSheetWithPresentingViewController:(id)vc registrationBlock:(id)reg loginBlock:(id)log;
- (void)showAddAcountUIAnimated:(BOOL)a1 addAccountSheetPresentingVC:(id)a2 entryPoint:(unsigned long long)a3 logger:(id)a4 multipleAccountHandler:(id)a5 accountSwitcher:(id)a6 cancelSwitchDestinationAppSurface:(id)a7;
@end

@interface IGAddAccountSheetViewController : UIViewController
@end

@interface IGSwitchUsersViewController : UIViewController
@end

@interface IGSSOAccountPickerViewController : UIViewController
@end

@interface IGURLHandler (SPKLock)
+ (BOOL)canOpenURL:(NSURL *)url;
+ (BOOL)openInternalURL:(NSURL *)url presentationConfig:(id)a1 controller:(id)a2 animated:(BOOL)a3 sourceURL:(id)a4 sourceMedia:(id)a5 ctaPresenterContext:(id)a6 loggingProvider:(id)a7 userSession:(id)a8 deviceSession:(id)a9 analyticsModule:(id)a10 annotation:(id)a11 sponsoredSupportConfiguration:(id)a12 isFromExternalDeeplink:(BOOL)a13;
+ (BOOL)openInternalURL:(NSURL *)url presentationConfig:(id)a1 controller:(id)a2 animated:(BOOL)a3 sourceURL:(id)a4 sourceMedia:(id)a5 ctaPresenterContext:(id)a6 loggingProvider:(id)a7 userSession:(id)a8 deviceSession:(id)a9 analyticsModule:(id)a10 sourceApplication:(id)a11 annotation:(id)a12 sponsoredSupportConfiguration:(id)a13 isFromExternalDeeplink:(BOOL)a14;
@end

// MARK: - Blocked Text Helpers

static BOOL SPKIsBlockedAccountText(NSString *raw) {
    if (!raw || ![raw isKindOfClass:[NSString class]]) return NO;
    NSString *t = raw.lowercaseString;
    if ([t containsString:@"deconect"] || // Deconectare, Deconectează-te, Deconectați-vă
        [t containsString:@"log out"] ||
        [t containsString:@"logout"] ||
        [t containsString:@"sign out"] ||
        [t containsString:@"adaug"] || // Adaugă un cont, Adăugare cont, etc.
        [t containsString:@"add account"] ||
        [t containsString:@"add an account"] ||
        [t containsString:@"comut"] || // Comută pe alt cont, Comutare conturi
        [t containsString:@"switch account"] ||
        [t containsString:@"switch user"] ||
        [t containsString:@"centru de conturi"] || // Centrul de conturi
        [t containsString:@"centrul de conturi"] ||
        [t containsString:@"administrare conturi"] ||
        [t containsString:@"account center"] ||
        [t containsString:@"accounts center"]) {
        return YES;
    }
    return NO;
}

static BOOL SPKViewContainsBlockedText(UIView *view) {
    if (!view) return NO;

    // Check accessibilityLabel on ANY UIView (critical for SwiftUI!)
    if ([view respondsToSelector:@selector(accessibilityLabel)]) {
        if (SPKIsBlockedAccountText(view.accessibilityLabel)) return YES;
    }
    if ([view respondsToSelector:@selector(accessibilityValue)]) {
        id val = [view valueForKey:@"accessibilityValue"];
        if ([val isKindOfClass:[NSString class]] && SPKIsBlockedAccountText((NSString *)val)) return YES;
    }

    // Check UILabel
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *lbl = (UILabel *)view;
        if (SPKIsBlockedAccountText(lbl.text)) return YES;
        if (SPKIsBlockedAccountText(lbl.attributedText.string)) return YES;
    }

    // Check UIButton
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        if (SPKIsBlockedAccountText([btn titleForState:UIControlStateNormal])) return YES;
        if (SPKIsBlockedAccountText(btn.titleLabel.text)) return YES;
    }

    // Check UITextView
    if ([view isKindOfClass:[UITextView class]]) {
        if (SPKIsBlockedAccountText(((UITextView *)view).text)) return YES;
    }

    for (UIView *sub in view.subviews) {
        if (SPKViewContainsBlockedText(sub)) return YES;
    }
    return NO;
}

static void SPKPurgeBlockedElementsInView(UIView *view) {
    if (!view) return;

    if ([view isKindOfClass:[UICollectionViewCell class]] || [view isKindOfClass:[UITableViewCell class]]) {
        if (SPKViewContainsBlockedText(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
            view.userInteractionEnabled = NO;
            if ([view respondsToSelector:@selector(contentView)]) {
                ((UICollectionViewCell *)view).contentView.hidden = YES;
                ((UICollectionViewCell *)view).contentView.alpha = 0.0;
                ((UICollectionViewCell *)view).contentView.userInteractionEnabled = NO;
            }
            return;
        }
    }

    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        if (SPKIsBlockedAccountText([btn titleForState:UIControlStateNormal]) ||
            SPKIsBlockedAccountText(btn.accessibilityLabel)) {
            btn.hidden = YES;
            btn.alpha = 0.0;
            btn.userInteractionEnabled = NO;
            [btn removeFromSuperview];
            return;
        }
    }

    // Check if the current view directly represents a blocked row/item
    if (SPKViewContainsBlockedText(view)) {
        NSString *cls = NSStringFromClass([view class]);
        if ([cls containsString:@"Row"] || [cls containsString:@"Cell"] || [cls containsString:@"Item"] || [cls containsString:@"Facepile"]) {
            view.hidden = YES;
            view.alpha = 0.0;
            view.userInteractionEnabled = NO;
            [view removeFromSuperview];
            return;
        }
    }

    for (UIView *sub in [view.subviews copy]) {
        SPKPurgeBlockedElementsInView(sub);
    }
}

// MARK: - Specialized Hooks (Settings2 Navigation Plugins)

%group SPKSettingsPluginsLockHooks

%hook IGLogoutS2NavigationPlugin

- (id)init {
    return nil;
}

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGLogoutS2NavigationPlugin action");
    return;
}

%end

%hook IGAddAccountS2NavigationPlugin

- (id)init {
    return nil;
}

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGAddAccountS2NavigationPlugin action");
    return;
}

%end

%hook IGAddNewProfessionalAccountS2NavigationPlugin

- (id)init {
    return nil;
}

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGAddNewProfessionalAccountS2NavigationPlugin action");
    return;
}

%end

%hook IGAccountsCenterS2NavigationPlugin

- (id)init {
    return nil;
}

%end

%hook IGAccountsCenterHorizontalFacepileView

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.hidden = YES;
    selfView.alpha = 0.0;
    selfView.userInteractionEnabled = NO;
    [selfView removeFromSuperview];
}

%end

%end // SPKSettingsPluginsLockHooks

// MARK: - Specialized Hooks (Profile Header & Title View)

%group SPKProfileTitleLockHooks

%hook _TtC21IGProfileTitleViewKit28IGProfileTitleViewController

- (BOOL)isTitleTappable {
    return NO;
}

- (void)setIsTitleTappable:(BOOL)val {
    %orig(NO);
}

- (void)_onTitleLabelTapped:(id)sender {
    return;
}

- (void)_onMultipleAccountsTapped:(id)sender {
    return;
}

- (void)_toggleSwitchUsersControl {
    return;
}

- (void)titleTapped:(id)sender {
    return;
}

- (void)titleTapped {
    return;
}

- (void)_titleButtonTapped {
    return;
}

- (void)titleButtonTapped {
    return;
}

- (void)onTitleLabelTapped:(id)sender {
    return;
}

- (void)onTitleTap {
    return;
}

- (void)titleViewControllerDidTapTitle:(id)sender {
    return;
}

- (void)titleViewControllerDidTapGhostBadge:(id)sender {
    return;
}

- (void)titleViewControllerWillToggleAccountTray:(id)sender on:(BOOL)on {
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewDidLayoutSubviews {
    %orig;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

%end

%hook IGProfileTitleViewController

- (void)_onTitleLabelTapped:(id)sender {
    return;
}

- (void)_onMultipleAccountsTapped:(id)sender {
    return;
}

- (void)_toggleSwitchUsersControl {
    return;
}

- (void)_displaySwitchUsersTableView:(BOOL)animated animated:(BOOL)arg2 completion:(id)completion {
    return;
}

- (void)_displaySwitchUsersTableView:(BOOL)animated animated:(BOOL)arg2 transitionDuration:(double)duration completion:(id)completion {
    return;
}

- (id)generateTitleViewWithRightBarButtonItems:(id)right leftBarButtonItems:(id)left user:(id)user {
    UIView *view = %orig;
    if (view && [view isKindOfClass:[UIView class]]) {
        view.userInteractionEnabled = NO;
        for (UIGestureRecognizer *g in [view.gestureRecognizers copy]) {
            [view removeGestureRecognizer:g];
        }
    }
    return view;
}

%end

%hook IGProfileTitleButton

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.userInteractionEnabled = NO;
    for (UIGestureRecognizer *g in [selfView.gestureRecognizers copy]) {
        [selfView removeGestureRecognizer:g];
    }
}

%end

%hook _TtC26IGProfileTitleViewKitSwift28IGProfileSingleUserTitleView

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.userInteractionEnabled = NO;
    for (UIGestureRecognizer *g in [selfView.gestureRecognizers copy]) {
        [selfView removeGestureRecognizer:g];
    }
}

%end

%hook _TtC21IGProfileTitleViewKit30IGGhostBadgeTitleButtonWrapper

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.userInteractionEnabled = NO;
    for (UIGestureRecognizer *g in [selfView.gestureRecognizers copy]) {
        [selfView removeGestureRecognizer:g];
    }
}

%end

%hook IGAccountTrayCollectionViewCell

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.hidden = YES;
    selfView.userInteractionEnabled = NO;
    [selfView removeFromSuperview];
}

%end

%end // SPKProfileTitleLockHooks

// MARK: - Core Switcher & Dialog Hooks

%group SPKCoreAccountLockHooks

%hook IGAccountSwitcher

- (long long)switchToUserWithPK:(id)pk
          destinationAppSurface:(id)surface
                 destinationURL:(id)url
                     entryPoint:(long long)point
                    loggingData:(id)data {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked switchToUserWithPK");
    return 0;
}

- (long long)switchToUser:(id)user
    destinationAppSurface:(id)surface
           destinationURL:(id)url
               entryPoint:(long long)point
              loggingData:(id)data {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked switchToUser");
    return 0;
}

- (void)showLogoutAlertDialogWithUserSession:(id)session entryPoint:(NSInteger)point {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked showLogoutAlertDialogWithUserSession");
    return;
}

- (void)logOutFromSwitcherWithUserSession:(id)session entryPoint:(NSInteger)point {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked logOutFromSwitcherWithUserSession");
    return;
}

%end

%hook IGAddAccountManager

- (void)presentAddAccountSheetWithPresentingViewController:(id)vc registrationBlock:(id)reg loginBlock:(id)log {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked presentAddAccountSheet");
    return;
}

- (void)showAddAcountUIAnimated:(BOOL)a1 addAccountSheetPresentingVC:(id)a2 entryPoint:(unsigned long long)a3 logger:(id)a4 multipleAccountHandler:(id)a5 accountSwitcher:(id)a6 cancelSwitchDestinationAppSurface:(id)a7 {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked showAddAcountUIAnimated");
    return;
}

%end

%hook IGAddAccountSheetViewController

- (void)loadView {
    %orig;
    ((UIViewController *)self).view.hidden = YES;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewDidLoad {
    %orig;
    ((UIViewController *)self).view.hidden = YES;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [((UIViewController *)self) dismissViewControllerAnimated:NO completion:nil];
}

%end

%hook IGSwitchUsersViewController

- (void)loadView {
    %orig;
    ((UIViewController *)self).view.hidden = YES;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewDidLoad {
    %orig;
    ((UIViewController *)self).view.hidden = YES;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [((UIViewController *)self) dismissViewControllerAnimated:NO completion:nil];
}

%end

%hook IGSSOAccountPickerViewController

- (void)loadView {
    %orig;
    ((UIViewController *)self).view.hidden = YES;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewDidLoad {
    %orig;
    ((UIViewController *)self).view.hidden = YES;
    ((UIViewController *)self).view.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [((UIViewController *)self) dismissViewControllerAnimated:NO completion:nil];
}

%end

%hook IGURLHandler

+ (BOOL)canOpenURL:(NSURL *)url {
    NSString *urlString = url.absoluteString.lowercaseString ?: @"";
    if ([urlString containsString:@"account_center"] ||
        [urlString containsString:@"accounts_center"] ||
        [urlString containsString:@"add_account"] ||
        [urlString containsString:@"switch_account"] ||
        [urlString containsString:@"logout"]) {
        return NO;
    }
    return %orig;
}

+ (BOOL)openInternalURL:(NSURL *)url
     presentationConfig:(id)a1
             controller:(id)a2
               animated:(BOOL)a3
              sourceURL:(id)a4
            sourceMedia:(id)a5
    ctaPresenterContext:(id)a6
        loggingProvider:(id)a7
            userSession:(id)a8
          deviceSession:(id)a9
        analyticsModule:(id)a10
             annotation:(id)a11
sponsoredSupportConfiguration:(id)a12
 isFromExternalDeeplink:(BOOL)a13 {
    NSString *urlString = url.absoluteString.lowercaseString ?: @"";
    if ([urlString containsString:@"account_center"] ||
        [urlString containsString:@"accounts_center"] ||
        [urlString containsString:@"add_account"] ||
        [urlString containsString:@"switch_account"] ||
        [urlString containsString:@"logout"]) {
        SPKLog(@"AccountLock", @"Blocked openInternalURL: %@", urlString);
        return NO;
    }
    return %orig;
}

+ (BOOL)openInternalURL:(NSURL *)url
     presentationConfig:(id)a1
             controller:(id)a2
               animated:(BOOL)a3
              sourceURL:(id)a4
            sourceMedia:(id)a5
    ctaPresenterContext:(id)a6
        loggingProvider:(id)a7
            userSession:(id)a8
          deviceSession:(id)a9
        analyticsModule:(id)a10
      sourceApplication:(id)a11
             annotation:(id)a12
sponsoredSupportConfiguration:(id)a13
 isFromExternalDeeplink:(BOOL)a14 {
    NSString *urlString = url.absoluteString.lowercaseString ?: @"";
    if ([urlString containsString:@"account_center"] ||
        [urlString containsString:@"accounts_center"] ||
        [urlString containsString:@"add_account"] ||
        [urlString containsString:@"switch_account"] ||
        [urlString containsString:@"logout"]) {
        SPKLog(@"AccountLock", @"Blocked openInternalURL with sourceApplication: %@", urlString);
        return NO;
    }
    return %orig;
}

%end

%end // SPKCoreAccountLockHooks

// MARK: - General UIKit Hooks (Always Active)

%group SPKGeneralLockUIHooks

%hook UIViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    NSString *clsName = NSStringFromClass([self class]);
    if ([clsName containsString:@"Settings"] || [clsName containsString:@"Settings2"] || [clsName containsString:@"HostingController"]) {
        SPKPurgeBlockedElementsInView(((UIViewController *)self).view);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSString *clsName = NSStringFromClass([self class]);
    if ([clsName containsString:@"Settings"] || [clsName containsString:@"Settings2"] || [clsName containsString:@"HostingController"]) {
        SPKPurgeBlockedElementsInView(((UIViewController *)self).view);
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    NSString *clsName = NSStringFromClass([self class]);
    // Profile page navigation bar: disable title view (username tap)
    if ([clsName containsString:@"Profile"] || [clsName containsString:@"GizmoProfile"]) {
        UIView *titleView = ((UIViewController *)self).navigationItem.titleView;
        if (titleView && titleView.userInteractionEnabled) {
            titleView.userInteractionEnabled = NO;
            for (UIGestureRecognizer *g in [titleView.gestureRecognizers copy]) {
                [titleView removeGestureRecognizer:g];
            }
        }
    }
    // Settings pages: purge any Add Account, Logout or Accounts Center cells/buttons
    if ([clsName containsString:@"Settings"] || [clsName containsString:@"Settings2"] || [clsName containsString:@"HostingController"]) {
        SPKPurgeBlockedElementsInView(((UIViewController *)self).view);
    }
}

%end

%hook UICollectionViewCell

- (void)layoutSubviews {
    %orig;
    if (SPKViewContainsBlockedText((UIView *)self)) {
        UICollectionViewCell *cell = (UICollectionViewCell *)self;
        cell.hidden = YES;
        cell.alpha = 0.0;
        cell.userInteractionEnabled = NO;
        cell.contentView.hidden = YES;
    }
}

%end

%hook UITableViewCell

- (void)layoutSubviews {
    %orig;
    if (SPKViewContainsBlockedText((UIView *)self)) {
        UITableViewCell *cell = (UITableViewCell *)self;
        cell.hidden = YES;
        cell.alpha = 0.0;
        cell.userInteractionEnabled = NO;
        cell.contentView.hidden = YES;
    }
}

%end

%hook UICollectionView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        CGPoint point = [touch locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
        if (indexPath) {
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
            if (cell && SPKViewContainsBlockedText(cell)) {
                SPKLog(@"AccountLock", @"Blocked touch on UICollectionView cell containing blocked text");
                return;
            }
        }
    }
    %orig;
}

%end

%hook UITableView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        CGPoint point = [touch locationInView:self];
        NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
        if (indexPath) {
            UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
            if (cell && SPKViewContainsBlockedText(cell)) {
                SPKLog(@"AccountLock", @"Blocked touch on UITableViewCell containing blocked text");
                return;
            }
        }
    }
    %orig;
}

%end

%end // SPKGeneralLockUIHooks

extern "C" void SPKInstallAccountSwitchHooksIfNeeded(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SPKLog(@"AccountLock", @"Installing AccountLock hooks...");

        // 1. Settings navigation plugins
        Class logoutPluginCls = SPKResolveIGClass(@"IGLogoutS2NavigationPlugin", @"IGLogoutS2NavigationPlugin");
        Class addPluginCls = SPKResolveIGClass(@"IGAddAccountS2NavigationPlugin", @"IGAddAccountS2NavigationPlugin");
        Class addProPluginCls = SPKResolveIGClass(@"IGAddNewProfessionalAccountS2NavigationPlugin", @"IGAddNewProfessionalAccountS2NavigationPlugin");
        Class accountsCenterPluginCls = SPKResolveIGClass(@"IGAccountsCenterS2NavigationPlugin", @"IGAccountsCenterS2NavigationPlugin");
        Class facepileCls = SPKResolveIGClass(@"IGAccountsCenterHorizontalFacepileView", @"IGAccountsCenterHorizontalFacepileView");

        if (logoutPluginCls || addPluginCls || addProPluginCls || accountsCenterPluginCls || facepileCls) {
            %init(SPKSettingsPluginsLockHooks,
                  IGLogoutS2NavigationPlugin = logoutPluginCls,
                  IGAddAccountS2NavigationPlugin = addPluginCls,
                  IGAddNewProfessionalAccountS2NavigationPlugin = addProPluginCls,
                  IGAccountsCenterS2NavigationPlugin = accountsCenterPluginCls,
                  IGAccountsCenterHorizontalFacepileView = facepileCls);
        }

        // 2. Profile title lock hooks
        Class swiftTitleVCCls = SPKResolveIGClass(@"IGProfileTitleViewKit.IGProfileTitleViewController", @"_TtC21IGProfileTitleViewKit28IGProfileTitleViewController");
        Class profileTitleCls = SPKResolveIGClass(@"IGProfileTitleViewController", @"IGProfileTitleViewController");
        Class titleButtonCls = SPKResolveIGClass(@"IGProfileTitleButton", @"IGProfileTitleButton");
        Class singleUserTitleCls = SPKResolveIGClass(@"IGProfileTitleViewKitSwift.IGProfileSingleUserTitleView", @"_TtC26IGProfileTitleViewKitSwift28IGProfileSingleUserTitleView");
        Class ghostBadgeCls = SPKResolveIGClass(@"IGProfileTitleViewKit.IGGhostBadgeTitleButtonWrapper", @"_TtC21IGProfileTitleViewKit30IGGhostBadgeTitleButtonWrapper");
        Class trayCellCls = SPKResolveIGClass(@"IGAccountTrayCollectionViewCell", @"IGAccountTrayCollectionViewCell");

        if (swiftTitleVCCls || profileTitleCls || titleButtonCls || singleUserTitleCls || ghostBadgeCls || trayCellCls) {
            %init(SPKProfileTitleLockHooks,
                  _TtC21IGProfileTitleViewKit28IGProfileTitleViewController = swiftTitleVCCls,
                  IGProfileTitleViewController = profileTitleCls,
                  IGProfileTitleButton = titleButtonCls,
                  _TtC26IGProfileTitleViewKitSwift28IGProfileSingleUserTitleView = singleUserTitleCls,
                  _TtC21IGProfileTitleViewKit30IGGhostBadgeTitleButtonWrapper = ghostBadgeCls,
                  IGAccountTrayCollectionViewCell = trayCellCls);
        }

        // 3. Core account switcher hooks
        Class accountSwitcherCls = SPKResolveIGClass(@"IGAccountSwitcher", @"IGAccountSwitcher");
        Class addManagerCls = SPKResolveIGClass(@"IGAddAccountManager", @"IGAddAccountManager");
        Class addSheetCls = SPKResolveIGClass(@"IGAddAccountSheetViewController", @"IGAddAccountSheetViewController");
        Class switchUsersCls = SPKResolveIGClass(@"IGSwitchUsersViewController", @"IGSwitchUsersViewController");
        Class ssoCls = SPKResolveIGClass(@"IGRegistration.IGSSOAccountPickerViewController", @"IGSSOAccountPickerViewController");
        Class urlHandlerCls = SPKResolveIGClass(@"IGURLHandler", @"IGURLHandler");

        if (accountSwitcherCls || addManagerCls || addSheetCls || switchUsersCls || ssoCls || urlHandlerCls) {
            %init(SPKCoreAccountLockHooks,
                  IGAccountSwitcher = accountSwitcherCls,
                  IGAddAccountManager = addManagerCls,
                  IGAddAccountSheetViewController = addSheetCls,
                  IGSwitchUsersViewController = switchUsersCls,
                  IGSSOAccountPickerViewController = ssoCls,
                  IGURLHandler = urlHandlerCls);
        }

        // 4. UIKit general layout & touch purge hooks
        %init(SPKGeneralLockUIHooks);
    });
}
