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

@interface _TtC15IGOneTapLoginUI33IGSingleOneTapLoginViewController : UIViewController
- (void)singleOneTapLoginViewDidTapLoginButton:(id)sender;
- (void)singleOneTapLoginViewDidTapSwitchAccountsButton:(id)sender;
- (void)singleOneTapLoginViewDidTapSignUpButton:(id)sender;
@end

@interface _TtC15IGOneTapLoginUI30IGOneTapSingleAccountLoginView : UIView
- (void)didTapSecondaryButton;
@end

@interface _TtC15IGOneTapLoginUI29IGMultiTapLoginViewController : UIViewController
- (void)multiTapLoginContainerViewDidTapSwitchAccountsButton:(id)sender;
- (void)multiTapLoginContainerViewDidTapSignUpButton:(id)sender;
@end

// MARK: - Blocked Text Helpers

static BOOL SPKIsBlockedAccountText(NSString *raw) {
    if (!raw || ![raw isKindOfClass:[NSString class]]) return NO;
    NSString *t = raw.lowercaseString;
    // Logout actions
    if ([t containsString:@"deconect"] || // Deconectare, Deconectează-te, Deconectați-vă
        [t containsString:@"log out"] ||
        [t containsString:@"logout"] ||
        [t containsString:@"sign out"]) {
        return YES;
    }
    // Add account actions
    if ([t containsString:@"adaugă un cont"] ||
        [t containsString:@"adauga un cont"] ||
        [t containsString:@"adaugă cont"] ||
        [t containsString:@"adauga cont"] ||
        [t containsString:@"adăugare cont"] ||
        [t containsString:@"adaugare cont"] ||
        [t containsString:@"adăugați un cont"] ||
        [t containsString:@"adaugati un cont"] ||
        [t containsString:@"add account"] ||
        [t containsString:@"add an account"] ||
        [t containsString:@"add existing account"] ||
        [t containsString:@"create new account"] ||
        [t containsString:@"creează un cont nou"] ||
        [t containsString:@"creeaza un cont nou"]) {
        return YES;
    }
    // Switch account actions
    if ([t containsString:@"comută pe alt cont"] ||
        [t containsString:@"comuta pe alt cont"] ||
        [t containsString:@"comută contul"] ||
        [t containsString:@"comuta contul"] ||
        [t containsString:@"comutare conturi"] ||
        [t containsString:@"comutare cont"] ||
        [t containsString:@"switch account"] ||
        [t containsString:@"switch user"] ||
        [t containsString:@"switch profile"]) {
        return YES;
    }
    // Accounts Center actions
    if ([t containsString:@"centru de conturi"] ||
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

    if ([view respondsToSelector:@selector(accessibilityLabel)]) {
        if (SPKIsBlockedAccountText(view.accessibilityLabel)) return YES;
    }

    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *lbl = (UILabel *)view;
        if (SPKIsBlockedAccountText(lbl.text)) return YES;
        if (SPKIsBlockedAccountText(lbl.attributedText.string)) return YES;
    }

    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        if (SPKIsBlockedAccountText([btn titleForState:UIControlStateNormal])) return YES;
        if (SPKIsBlockedAccountText(btn.titleLabel.text)) return YES;
    }

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
            return;
        }
    }

    if (SPKViewContainsBlockedText(view)) {
        NSString *cls = NSStringFromClass([view class]);
        if ([cls containsString:@"Row"] || [cls containsString:@"Cell"] || [cls containsString:@"Facepile"]) {
            view.hidden = YES;
            view.alpha = 0.0;
            view.userInteractionEnabled = NO;
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

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGLogoutS2NavigationPlugin action");
    return;
}

%end

%hook IGAddAccountS2NavigationPlugin

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGAddAccountS2NavigationPlugin action");
    return;
}

%end

%hook IGAddNewProfessionalAccountS2NavigationPlugin

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGAddNewProfessionalAccountS2NavigationPlugin action");
    return;
}

%end

%hook IGAccountsCenterHorizontalFacepileView

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.hidden = YES;
    selfView.alpha = 0.0;
    selfView.userInteractionEnabled = NO;
}

- (void)didMoveToSuperview {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.hidden = YES;
    selfView.alpha = 0.0;
    selfView.userInteractionEnabled = NO;
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

// MARK: - General UIKit Hooks (Settings and UI Lockdown)

static UIViewController *SPKFindViewController(UIResponder *responder) {
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = responder.nextResponder;
    }
    return (UIViewController *)responder;
}

static BOOL SPKIsSettingsViewController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *clsName = NSStringFromClass([vc class]);
    return [clsName containsString:@"Settings"] ||
           [clsName containsString:@"Settings2"] ||
           [clsName containsString:@"Menu"] ||
           [clsName containsString:@"ActionSheet"] ||
           [clsName containsString:@"HostingController"];
}

%group SPKGeneralLockUIHooks

%hook UIViewController

- (void)viewDidLayoutSubviews {
    %orig;
    NSString *clsName = NSStringFromClass([self class]);
    if ([clsName containsString:@"Profile"] || [clsName containsString:@"GizmoProfile"]) {
        UIView *titleView = ((UIViewController *)self).navigationItem.titleView;
        if (titleView && titleView.userInteractionEnabled) {
            titleView.userInteractionEnabled = NO;
            for (UIGestureRecognizer *g in [titleView.gestureRecognizers copy]) {
                [titleView removeGestureRecognizer:g];
            }
        }
    }
    if ([clsName containsString:@"Settings"] || [clsName containsString:@"Settings2"] || [clsName containsString:@"HostingController"]) {
        SPKPurgeBlockedElementsInView(((UIViewController *)self).view);
    }
}

%end

%hook UITableViewCell

- (void)layoutSubviews {
    %orig;
    UIViewController *vc = SPKFindViewController(self);
    if (!SPKIsSettingsViewController(vc)) return;
    if (SPKViewContainsBlockedText((UIView *)self)) {
        UITableViewCell *cell = (UITableViewCell *)self;
        cell.hidden = YES;
        cell.alpha = 0.0;
        cell.userInteractionEnabled = NO;
        cell.contentView.hidden = YES;
    }
}

%end

%hook UITableView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIViewController *vc = SPKFindViewController(self);
    if (!SPKIsSettingsViewController(vc)) {
        %orig;
        return;
    }
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

// MARK: - Auto-Login & Switch Block Hooks for One Tap Login

%group SPKOneTapAutoLoginHooks

%hook _TtC15IGOneTapLoginUI33IGSingleOneTapLoginViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static CFAbsoluteTime s_lastAutoLogin = 0;
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (now - s_lastAutoLogin > 2.0) {
        s_lastAutoLogin = now;
        SPKLog(@"AccountLock", @"Auto-triggering singleOneTapLoginViewDidTapLoginButton");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {
                if ([self respondsToSelector:@selector(singleOneTapLoginViewDidTapLoginButton:)]) {
                    [self performSelector:@selector(singleOneTapLoginViewDidTapLoginButton:) withObject:nil];
                }
            } @catch (NSException *e) {
                SPKLog(@"AccountLock", @"Auto-login exception: %@", e);
            }
        });
    }
}

- (void)singleOneTapLoginViewDidTapSwitchAccountsButton:(id)sender {
    SPKLog(@"AccountLock", @"Blocked singleOneTapLoginViewDidTapSwitchAccountsButton");
    return;
}

- (void)singleOneTapLoginViewDidTapSignUpButton:(id)sender {
    SPKLog(@"AccountLock", @"Blocked singleOneTapLoginViewDidTapSignUpButton");
    return;
}

%end

%hook _TtC15IGOneTapLoginUI30IGOneTapSingleAccountLoginView

- (void)didTapSecondaryButton {
    SPKLog(@"AccountLock", @"Blocked didTapSecondaryButton on IGOneTapSingleAccountLoginView");
    return;
}

%end

%hook _TtC15IGOneTapLoginUI29IGMultiTapLoginViewController

- (void)multiTapLoginContainerViewDidTapSwitchAccountsButton:(id)sender {
    SPKLog(@"AccountLock", @"Blocked multiTapLoginContainerViewDidTapSwitchAccountsButton");
    return;
}

- (void)multiTapLoginContainerViewDidTapSignUpButton:(id)sender {
    SPKLog(@"AccountLock", @"Blocked multiTapLoginContainerViewDidTapSignUpButton");
    return;
}

%end

%end // SPKOneTapAutoLoginHooks

extern "C" void SPKInstallAccountSwitchHooksIfNeeded(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SPKLog(@"AccountLock", @"Installing AccountLock hooks...");

        Class logoutPluginCls = SPKResolveIGClass(@"IGLogoutS2NavigationPlugin", @"IGLogoutS2NavigationPlugin");
        Class addPluginCls = SPKResolveIGClass(@"IGAddAccountS2NavigationPlugin", @"IGAddAccountS2NavigationPlugin");
        Class addProPluginCls = SPKResolveIGClass(@"IGAddNewProfessionalAccountS2NavigationPlugin", @"IGAddNewProfessionalAccountS2NavigationPlugin");
        Class facepileCls = SPKResolveIGClass(@"IGAccountsCenterHorizontalFacepileView", @"IGAccountsCenterHorizontalFacepileView");

        if (logoutPluginCls || addPluginCls || addProPluginCls || facepileCls) {
            %init(SPKSettingsPluginsLockHooks,
                  IGLogoutS2NavigationPlugin = logoutPluginCls,
                  IGAddAccountS2NavigationPlugin = addPluginCls,
                  IGAddNewProfessionalAccountS2NavigationPlugin = addProPluginCls,
                  IGAccountsCenterHorizontalFacepileView = facepileCls);
        }

        Class swiftTitleVCCls = SPKResolveIGClass(@"IGProfileTitleViewKit.IGProfileTitleViewController", @"_TtC21IGProfileTitleViewKit28IGProfileTitleViewController");
        Class profileTitleCls = SPKResolveIGClass(@"IGProfileTitleViewController", @"IGProfileTitleViewController");
        Class titleButtonCls = SPKResolveIGClass(@"IGProfileTitleButton", @"IGProfileTitleButton");
        Class singleUserTitleCls = SPKResolveIGClass(@"IGProfileTitleViewKitSwift.IGProfileSingleUserTitleView", @"_TtC26IGProfileTitleViewKitSwift28IGProfileSingleUserTitleView");
        Class ghostBadgeCls = SPKResolveIGClass(@"IGProfileTitleViewKit.IGGhostBadgeTitleButtonWrapper", @"_TtC21IGProfileTitleViewKit30IGGhostBadgeTitleButtonWrapper");

        if (swiftTitleVCCls || profileTitleCls || titleButtonCls || singleUserTitleCls || ghostBadgeCls) {
            %init(SPKProfileTitleLockHooks,
                  _TtC21IGProfileTitleViewKit28IGProfileTitleViewController = swiftTitleVCCls,
                  IGProfileTitleViewController = profileTitleCls,
                  IGProfileTitleButton = titleButtonCls,
                  _TtC26IGProfileTitleViewKitSwift28IGProfileSingleUserTitleView = singleUserTitleCls,
                  _TtC21IGProfileTitleViewKit30IGGhostBadgeTitleButtonWrapper = ghostBadgeCls);
        }

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

        Class singleOneTapCls = SPKResolveIGClass(@"IGOneTapLoginUI.IGSingleOneTapLoginViewController", @"_TtC15IGOneTapLoginUI33IGSingleOneTapLoginViewController");
        Class singleAccountViewCls = SPKResolveIGClass(@"IGOneTapLoginUI.IGOneTapSingleAccountLoginView", @"_TtC15IGOneTapLoginUI30IGOneTapSingleAccountLoginView");
        Class multiTapCls = SPKResolveIGClass(@"IGOneTapLoginUI.IGMultiTapLoginViewController", @"_TtC15IGOneTapLoginUI29IGMultiTapLoginViewController");

        if (singleOneTapCls || singleAccountViewCls || multiTapCls) {
            %init(SPKOneTapAutoLoginHooks,
                  _TtC15IGOneTapLoginUI33IGSingleOneTapLoginViewController = singleOneTapCls,
                  _TtC15IGOneTapLoginUI30IGOneTapSingleAccountLoginView = singleAccountViewCls,
                  _TtC15IGOneTapLoginUI29IGMultiTapLoginViewController = multiTapCls);
        }

        %init(SPKGeneralLockUIHooks);
    });
}
