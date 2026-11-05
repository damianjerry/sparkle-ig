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

@interface _TtC21IGProfileTitleViewKit28IGProfileTitleViewController : NSObject
- (BOOL)isTitleTappable;
- (void)setIsTitleTappable:(BOOL)val;
- (void)onTitleTap;
- (void)onTitleTap:(id)sender;
- (void)onTitleTapped:(id)sender;
- (void)onTitleTapped;
- (void)onTitleLabelTapped:(id)sender;
- (void)onGhostBadgeTapped:(id)sender;
- (void)onMultipleAccountsTapped:(id)sender;
- (id)titleLabelView;
- (id)generateTitleViewWithRightBarButtonItems:(id)right leftBarButtonItems:(id)left userAccess:(id)access leftAlignUsernameForSimplerHeader:(BOOL)leftAlign shouldAdjustFontSizeToFitWidth:(BOOL)adjust;
@end

@interface IGAccountSwitcher (SPKLock)
- (void)showAccountSwitcher;
- (void)_openMultiAccountSwitcher;
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

@interface _TtC18IdentitySwitcherUI30IdentitySwitcherViewController : UIViewController
@end

@interface _TtC18IdentitySwitcherUI40IdentitySwitcherAddAccountViewController : UIViewController
@end

@interface _TtC18IdentitySwitcherUI40IdentitySwitcherAddProfileViewController : UIViewController
@end

@interface _TtC18IdentitySwitcherUI41IdentitySwitcherMenuOptionsViewController : UIViewController
@end

@interface IGActionableConfirmationToastPresenter : NSObject
- (void)showAccountSwitcherPartialSheet:(id)sheet completion:(id)comp;
@end

@interface IGAutoLoginManager : NSObject
- (id)initWithAuthenticator:(id)auth accountStoreCoordinator:(id)coord multipleAccountHandler:(id)handler isLoggingOut:(BOOL)loggingOut;
- (BOOL)isLoggingOut;
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
- (void)didTapLoginButton;
- (void)_didTapLoginButton;
- (void)didTapPrimaryButton;
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
    // Add account / profile / device actions
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
        [t containsString:@"creeaza un cont nou"] ||
        [t containsString:@"adaugă profil"] ||
        [t containsString:@"adauga profil"] ||
        [t containsString:@"adaugă mai multe"] ||
        [t containsString:@"adauga mai multe"] ||
        [t containsString:@"adaugă instagram"] ||
        [t containsString:@"adauga instagram"] ||
        [t containsString:@"adaugă facebook"] ||
        [t containsString:@"adauga facebook"] ||
        [t containsString:@"adaugă dispozitiv"] ||
        [t containsString:@"adauga dispozitiv"] ||
        [t containsString:@"add profile"] ||
        [t containsString:@"add profiles"] ||
        [t containsString:@"add more"] ||
        [t containsString:@"add instagram"] ||
        [t containsString:@"add facebook"] ||
        [t containsString:@"add device"]) {
        return YES;
    }
    // Switch account / profile actions
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
    // Accounts Center & multi-profile actions
    if ([t containsString:@"centru de conturi"] ||
        [t containsString:@"centrul de conturi"] ||
        [t containsString:@"administrare conturi"] ||
        [t containsString:@"administrează contul"] ||
        [t containsString:@"administreaza contul"] ||
        [t containsString:@"experiențe multiprofil"] ||
        [t containsString:@"experiente multiprofil"] ||
        [t containsString:@"contului de meta"] ||
        [t containsString:@"contul de meta"] ||
        [t containsString:@"account center"] ||
        [t containsString:@"accounts center"]) {
        return YES;
    }
    return NO;
}

static BOOL SPKViewContainsBlockedText(UIView *view) {
    if (!view) return NO;

    if ([view.accessibilityIdentifier isEqualToString:@"profile-app-switch-button"]) return YES;

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

    if ([view.accessibilityIdentifier isEqualToString:@"profile-app-switch-button"]) {
        view.hidden = YES;
        view.alpha = 0.0;
        view.userInteractionEnabled = NO;
        return;
    }

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

    if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UIControl class]]) {
        if (SPKViewContainsBlockedText(view)) {
            view.hidden = YES;
            view.alpha = 0.0;
            view.userInteractionEnabled = NO;
            return;
        }
    }

    if (SPKViewContainsBlockedText(view)) {
        NSString *cls = NSStringFromClass([view class]);
        if ([cls containsString:@"Row"] || [cls containsString:@"Cell"] || [cls containsString:@"Facepile"] || [cls containsString:@"Item"] || [cls containsString:@"Button"]) {
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

%hook IGAccountsCenterS2NavigationPlugin

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGAccountsCenterS2NavigationPlugin action");
    return;
}

%end

%hook IGAccountLinkingS2NavigationPlugin

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGAccountLinkingS2NavigationPlugin action");
    return;
}

%end

%hook IGPermissionsLeaveSharedAccountS2NavigationPlugin

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGPermissionsLeaveSharedAccountS2NavigationPlugin action");
    return;
}

%end

%hook IGPermissionsSharedAccessS2NavigationPlugin

- (void)performActionWithNavigationController:(id)nav userSession:(id)session {
    SPKLog(@"AccountLock", @"Blocked IGPermissionsSharedAccessS2NavigationPlugin action");
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
    for (UIGestureRecognizer *g in [selfView.gestureRecognizers copy]) {
        [selfView removeGestureRecognizer:g];
    }
}

- (void)didMoveToSuperview {
    %orig;
    UIView *selfView = (UIView *)self;
    selfView.hidden = YES;
    selfView.alpha = 0.0;
    selfView.userInteractionEnabled = NO;
    for (UIGestureRecognizer *g in [selfView.gestureRecognizers copy]) {
        [selfView removeGestureRecognizer:g];
    }
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

- (void)onTitleTap {
    return;
}

- (void)onTitleTap:(id)sender {
    return;
}

- (void)onTitleTapped:(id)sender {
    return;
}

- (void)onTitleTapped {
    return;
}

- (void)onTitleLabelTapped:(id)sender {
    return;
}

- (void)onGhostBadgeTapped:(id)sender {
    return;
}

- (void)onMultipleAccountsTapped:(id)sender {
    return;
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

- (id)titleLabelView {
    UIView *view = %orig;
    if (view && [view isKindOfClass:[UIView class]]) {
        view.userInteractionEnabled = NO;
        for (UIGestureRecognizer *g in [view.gestureRecognizers copy]) {
            [view removeGestureRecognizer:g];
        }
    }
    return view;
}

- (id)generateTitleViewWithRightBarButtonItems:(id)right leftBarButtonItems:(id)left userAccess:(id)access leftAlignUsernameForSimplerHeader:(BOOL)leftAlign shouldAdjustFontSizeToFitWidth:(BOOL)adjust {
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

- (void)showAccountSwitcher {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked showAccountSwitcher");
    return;
}

- (void)_openMultiAccountSwitcher {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked _openMultiAccountSwitcher");
    return;
}

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

%hook _TtC18IdentitySwitcherUI30IdentitySwitcherViewController

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

%hook _TtC18IdentitySwitcherUI40IdentitySwitcherAddAccountViewController

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

%hook _TtC18IdentitySwitcherUI40IdentitySwitcherAddProfileViewController

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

%hook _TtC18IdentitySwitcherUI41IdentitySwitcherMenuOptionsViewController

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

%hook IGActionableConfirmationToastPresenter

- (void)showAccountSwitcherPartialSheet:(id)sheet completion:(id)comp {
    SPKLog(@"AccountLock", @"Blocked showAccountSwitcherPartialSheet on IGActionableConfirmationToastPresenter");
    if (comp) ((void (^)(void))comp)();
    return;
}

%end

%hook IGAutoLoginManager

- (id)initWithAuthenticator:(id)auth accountStoreCoordinator:(id)coord multipleAccountHandler:(id)handler isLoggingOut:(BOOL)loggingOut {
    SPKLog(@"AccountLock", @"IGAutoLoginManager init with isLoggingOut: NO");
    return %orig(auth, coord, handler, NO);
}

- (BOOL)isLoggingOut {
    return NO;
}

%end

%hook IGURLHandler

+ (BOOL)canOpenURL:(NSURL *)url {
    NSString *urlString = url.absoluteString.lowercaseString ?: @"";
    if ([urlString containsString:@"account_center"] ||
        [urlString containsString:@"accounts_center"] ||
        [urlString containsString:@"add_account"] ||
        [urlString containsString:@"switch_account"] ||
        [urlString containsString:@"profile_switcher"] ||
        [urlString containsString:@"identity_switcher"] ||
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
        [urlString containsString:@"profile_switcher"] ||
        [urlString containsString:@"identity_switcher"] ||
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
        [urlString containsString:@"profile_switcher"] ||
        [urlString containsString:@"identity_switcher"] ||
        [urlString containsString:@"logout"]) {
        SPKLog(@"AccountLock", @"Blocked openInternalURL with sourceApplication: %@", urlString);
        return NO;
    }
    return %orig;
}

%end

%end // SPKCoreAccountLockHooks

// MARK: - General UIKit Hooks (Settings and UI Lockdown)

static BOOL SPKIsSettingsOrAccountsViewController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *clsName = NSStringFromClass([vc class]);
    return [clsName containsString:@"Settings"] ||
           [clsName containsString:@"Settings2"] ||
           [clsName containsString:@"Menu"] ||
           [clsName containsString:@"ActionSheet"] ||
           [clsName containsString:@"HostingController"] ||
           [clsName containsString:@"Bloks"] ||
           [clsName containsString:@"BK"] ||
           [clsName containsString:@"AccountsCenter"] ||
           [clsName containsString:@"FX"];
}

%group SPKGeneralLockUIHooks

%hook UIViewController

- (void)showAccountSwitcherPartialSheet:(id)sheet completion:(id)comp {
    SPKLog(@"AccountLock", @"Blocked showAccountSwitcherPartialSheet on UIViewController");
    if (comp) {
        ((void (^)(void))comp)();
    }
    return;
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)flag completion:(void (^)(void))comp {
    NSString *clsName = NSStringFromClass([vc class]);
    if ([clsName containsString:@"IdentitySwitcher"] ||
        [clsName containsString:@"AccountSwitcher"] ||
        [clsName containsString:@"SwitchUsers"] ||
        [clsName containsString:@"AddAccount"] ||
        [clsName containsString:@"SSOAccountPicker"]) {
        SPKLog(@"AccountLock", @"Blocked presentViewController for %@", clsName);
        if (comp) comp();
        return;
    }
    %orig;
}

- (void)viewDidLayoutSubviews {
    %orig;
    NSString *clsName = NSStringFromClass([self class]);
    if ([clsName containsString:@"Profile"] || [clsName containsString:@"GizmoProfile"]) {
        UIView *titleView = ((UIViewController *)self).navigationItem.titleView;
        if (titleView) {
            titleView.userInteractionEnabled = NO;
            for (UIGestureRecognizer *g in [titleView.gestureRecognizers copy]) {
                [titleView removeGestureRecognizer:g];
            }
            for (UIView *sub in titleView.subviews) {
                sub.userInteractionEnabled = NO;
                for (UIGestureRecognizer *g in [sub.gestureRecognizers copy]) {
                    [sub removeGestureRecognizer:g];
                }
            }
        }
    }
    if (SPKIsSettingsOrAccountsViewController((UIViewController *)self)) {
        SPKPurgeBlockedElementsInView(((UIViewController *)self).view);
    }
}

%end

%hook UIControl

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (SPKViewContainsBlockedText((UIView *)self)) {
        SPKLog(@"AccountLock", @"Blocked UIControl sendAction:%@ on view with blocked text", NSStringFromSelector(action));
        return;
    }
    if ([self.accessibilityIdentifier isEqualToString:@"profile-app-switch-button"]) {
        SPKLog(@"AccountLock", @"Blocked profile-app-switch-button UIControl");
        return;
    }
    %orig;
}

%end

%hook UIGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *v = self.view;
    if (v && (SPKViewContainsBlockedText(v) || [v.accessibilityIdentifier isEqualToString:@"profile-app-switch-button"])) {
        SPKLog(@"AccountLock", @"Blocked gesture on view with blocked text/identifier");
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    %orig;
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

%hook UICollectionView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch) {
        CGPoint point = [touch locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
        if (indexPath) {
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
            if (cell && SPKViewContainsBlockedText(cell)) {
                SPKLog(@"AccountLock", @"Blocked touch on UICollectionViewCell containing blocked text");
                return;
            }
        }
    }
    %orig;
}

%end

%end // SPKGeneralLockUIHooks

// MARK: - Auto-Login & Switch Block Hooks for One Tap Login

static void SPKTriggerSingleAccountLogin(id viewOrVC) {
    if (!viewOrVC) return;
    static CFAbsoluteTime s_lastAttempt = 0;
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (now - s_lastAttempt < 0.5) return;
    s_lastAttempt = now;

    UIView *view = nil;
    if ([viewOrVC isKindOfClass:[UIViewController class]]) {
        view = ((UIViewController *)viewOrVC).view;
    } else if ([viewOrVC isKindOfClass:[UIView class]]) {
        view = (UIView *)viewOrVC;
    }
    if (!view) return;

    SPKLog(@"AccountLock", @"Triggering auto-login from %@", [view class]);

    // 1. Check if view has a delegate conforming to singleOneTapLoginViewDidTapLoginButton:
    @try {
        if ([view respondsToSelector:@selector(delegate)]) {
            id del = [view performSelector:@selector(delegate)];
            if (del && [del respondsToSelector:@selector(singleOneTapLoginViewDidTapLoginButton:)]) {
                SPKLog(@"AccountLock", @"Calling singleOneTapLoginViewDidTapLoginButton on delegate");
                [del performSelector:@selector(singleOneTapLoginViewDidTapLoginButton:) withObject:view];
                return;
            }
        }
    } @catch (NSException *e) {
        SPKLog(@"AccountLock", @"Delegate trigger exception: %@", e);
    }

    // 2. Direct action methods on view
    if ([view respondsToSelector:@selector(didTapLoginButton)]) {
        SPKLog(@"AccountLock", @"Calling didTapLoginButton on view");
        [view performSelector:@selector(didTapLoginButton)];
        return;
    }
    if ([view respondsToSelector:@selector(_didTapLoginButton)]) {
        SPKLog(@"AccountLock", @"Calling _didTapLoginButton on view");
        [view performSelector:@selector(_didTapLoginButton)];
        return;
    }
    if ([view respondsToSelector:@selector(didTapPrimaryButton)]) {
        SPKLog(@"AccountLock", @"Calling didTapPrimaryButton on view");
        [view performSelector:@selector(didTapPrimaryButton)];
        return;
    }

    // 3. Search subviews for login button and simulate tap
    NSMutableArray<UIView *> *queue = [NSMutableArray arrayWithObject:view];
    while (queue.count > 0) {
        UIView *curr = queue.firstObject;
        [queue removeObjectAtIndex:0];

        if ([curr isKindOfClass:[UIControl class]]) {
            UIControl *ctrl = (UIControl *)curr;
            NSString *title = @"";
            if ([ctrl isKindOfClass:[UIButton class]]) {
                title = [((UIButton *)ctrl) titleForState:UIControlStateNormal] ?: @"";
            }
            NSString *low = title.lowercaseString;
            // Ignore cancel / switch / remove / alt
            if (![low containsString:@"switch"] && ![low containsString:@"comut"] &&
                ![low containsString:@"cancel"] && ![low containsString:@"renunț"] &&
                ![low containsString:@"remove"] && ![low containsString:@"șterge"]) {
                SPKLog(@"AccountLock", @"Sending TouchUpInside to login control: %@", title);
                [ctrl sendActionsForControlEvents:UIControlEventTouchUpInside];
                return;
            }
        }

        [queue addObjectsFromArray:curr.subviews];
    }
}

%group SPKOneTapAutoLoginHooks

%hook _TtC15IGOneTapLoginUI33IGSingleOneTapLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    dispatch_async(dispatch_get_main_queue(), ^{
        SPKTriggerSingleAccountLogin(self.view);
    });
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SPKTriggerSingleAccountLogin(self.view);
    });
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

- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SPKTriggerSingleAccountLogin((UIView *)self);
        });
    }
}

- (void)layoutSubviews {
    %orig;
    static BOOL s_layoutTriggered = NO;
    if (!s_layoutTriggered && self.window) {
        s_layoutTriggered = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SPKTriggerSingleAccountLogin((UIView *)self);
        });
    }
}

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
        Class accountsCenterPluginCls = SPKResolveIGClass(@"IGAccountsCenterS2NavigationPlugin", @"IGAccountsCenterS2NavigationPlugin");
        Class accountLinkingPluginCls = SPKResolveIGClass(@"IGAccountLinkingS2NavigationPlugin", @"IGAccountLinkingS2NavigationPlugin");
        Class leaveSharedPluginCls = SPKResolveIGClass(@"IGPermissionsLeaveSharedAccountS2NavigationPlugin", @"IGPermissionsLeaveSharedAccountS2NavigationPlugin");
        Class sharedAccessPluginCls = SPKResolveIGClass(@"IGPermissionsSharedAccessS2NavigationPlugin", @"IGPermissionsSharedAccessS2NavigationPlugin");
        Class facepileCls = SPKResolveIGClass(@"IGAccountsCenterHorizontalFacepileView", @"IGAccountsCenterHorizontalFacepileView");

        if (logoutPluginCls || addPluginCls || addProPluginCls || accountsCenterPluginCls ||
            accountLinkingPluginCls || leaveSharedPluginCls || sharedAccessPluginCls || facepileCls) {
            %init(SPKSettingsPluginsLockHooks,
                  IGLogoutS2NavigationPlugin = logoutPluginCls,
                  IGAddAccountS2NavigationPlugin = addPluginCls,
                  IGAddNewProfessionalAccountS2NavigationPlugin = addProPluginCls,
                  IGAccountsCenterS2NavigationPlugin = accountsCenterPluginCls,
                  IGAccountLinkingS2NavigationPlugin = accountLinkingPluginCls,
                  IGPermissionsLeaveSharedAccountS2NavigationPlugin = leaveSharedPluginCls,
                  IGPermissionsSharedAccessS2NavigationPlugin = sharedAccessPluginCls,
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
        Class idSwitcherCls = SPKResolveIGClass(@"IdentitySwitcherUI.IdentitySwitcherViewController", @"_TtC18IdentitySwitcherUI30IdentitySwitcherViewController");
        Class idAddAccountCls = SPKResolveIGClass(@"IdentitySwitcherUI.IdentitySwitcherAddAccountViewController", @"_TtC18IdentitySwitcherUI40IdentitySwitcherAddAccountViewController");
        Class idAddProfileCls = SPKResolveIGClass(@"IdentitySwitcherUI.IdentitySwitcherAddProfileViewController", @"_TtC18IdentitySwitcherUI40IdentitySwitcherAddProfileViewController");
        Class idMenuOptionsCls = SPKResolveIGClass(@"IdentitySwitcherUI.IdentitySwitcherMenuOptionsViewController", @"_TtC18IdentitySwitcherUI41IdentitySwitcherMenuOptionsViewController");
        Class toastPresenterCls = SPKResolveIGClass(@"IGActionableConfirmationToastPresenter", @"IGActionableConfirmationToastPresenter");
        Class autoLoginMgrCls = SPKResolveIGClass(@"IGAutoLoginManager", @"IGAutoLoginManager");
        Class urlHandlerCls = SPKResolveIGClass(@"IGURLHandler", @"IGURLHandler");

        if (accountSwitcherCls || addManagerCls || addSheetCls || switchUsersCls || ssoCls ||
            idSwitcherCls || idAddAccountCls || idAddProfileCls || idMenuOptionsCls ||
            toastPresenterCls || autoLoginMgrCls || urlHandlerCls) {
            %init(SPKCoreAccountLockHooks,
                  IGAccountSwitcher = accountSwitcherCls,
                  IGAddAccountManager = addManagerCls,
                  IGAddAccountSheetViewController = addSheetCls,
                  IGSwitchUsersViewController = switchUsersCls,
                  IGSSOAccountPickerViewController = ssoCls,
                  _TtC18IdentitySwitcherUI30IdentitySwitcherViewController = idSwitcherCls,
                  _TtC18IdentitySwitcherUI40IdentitySwitcherAddAccountViewController = idAddAccountCls,
                  _TtC18IdentitySwitcherUI40IdentitySwitcherAddProfileViewController = idAddProfileCls,
                  _TtC18IdentitySwitcherUI41IdentitySwitcherMenuOptionsViewController = idMenuOptionsCls,
                  IGActionableConfirmationToastPresenter = toastPresenterCls,
                  IGAutoLoginManager = autoLoginMgrCls,
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

__attribute__((constructor)) static void SPKInitAccountSwitchEarly(void) {
    SPKInstallAccountSwitchHooksIfNeeded();
}
