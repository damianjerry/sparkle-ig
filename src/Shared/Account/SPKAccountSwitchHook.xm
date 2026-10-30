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
- (id)_newMultipleAccountsTitleButtonWithTitle:(id)title showLock:(BOOL)lock user:(id)user maxWidth:(double)maxWidth;
- (id)_newSingleUserTitleViewWithTitle:(id)title showLock:(BOOL)lock showVerifiedBadge:(BOOL)badge;
@end

@interface IGProfileNavigationHeaderView : UIView
@end

@interface IGAccountSwitcher : NSObject
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

@interface IGURLHandler : NSObject
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
        [t containsString:@"adaugă un cont"] || // Adaugă un cont
        [t containsString:@"adaugă cont"] ||
        [t containsString:@"adauga un cont"] ||
        [t containsString:@"adauga cont"] ||
        [t containsString:@"add account"] ||
        [t containsString:@"add an account"] ||
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
    if ([view isKindOfClass:[UILabel class]]) {
        if (SPKIsBlockedAccountText(((UILabel *)view).text)) return YES;
    }
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        if (SPKIsBlockedAccountText([btn titleForState:UIControlStateNormal])) return YES;
        if (SPKIsBlockedAccountText(btn.accessibilityLabel)) return YES;
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
    
    for (UIView *sub in [view.subviews copy]) {
        SPKPurgeBlockedElementsInView(sub);
    }
}

// MARK: - Specialized Hooks (Instagram Classes)

%group SPKSingleAccountLockHooks

// 1. Block IGAccountSwitcher completely (Account switching + Logout dialogs)
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

// 2. Block profile title controller taps (Legacy and intermediate IG builds)
%hook IGProfileTitleViewController

- (void)_onTitleLabelTapped:(id)sender {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked profile title label tap");
    return;
}

- (void)_onMultipleAccountsTapped:(id)sender {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked profile multiple accounts tap");
    return;
}

- (void)_toggleSwitchUsersControl {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked toggleSwitchUsersControl");
    return;
}

- (void)_displaySwitchUsersTableView:(BOOL)animated animated:(BOOL)arg2 completion:(id)completion {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked _displaySwitchUsersTableView");
    return;
}

- (void)_displaySwitchUsersTableView:(BOOL)animated animated:(BOOL)arg2 transitionDuration:(double)duration completion:(id)completion {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked _displaySwitchUsersTableView with duration");
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

- (id)_newMultipleAccountsTitleButtonWithTitle:(id)title showLock:(BOOL)lock user:(id)user maxWidth:(double)maxWidth {
    UIView *view = %orig;
    if (view && [view isKindOfClass:[UIView class]]) {
        view.userInteractionEnabled = NO;
    }
    return view;
}

- (id)_newSingleUserTitleViewWithTitle:(id)title showLock:(BOOL)lock showVerifiedBadge:(BOOL)badge {
    UIView *view = %orig;
    if (view && [view isKindOfClass:[UIView class]]) {
        view.userInteractionEnabled = NO;
    }
    return view;
}

%end

// 3. Block profile navigation header title view interactions (Modern IG profile header)
%hook IGProfileNavigationHeaderView

- (void)layoutSubviews {
    %orig;
    UIView *selfView = (UIView *)self;
    for (UIView *sub in selfView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            // The username/account switcher button is situated away from the trailing menu edge (+ and ≡)
            if (btn.frame.origin.x < (selfView.bounds.size.width - 100)) {
                btn.userInteractionEnabled = NO;
                for (UIGestureRecognizer *g in [btn.gestureRecognizers copy]) {
                    [btn removeGestureRecognizer:g];
                }
            }
        }
    }
    UIView *titleView = nil;
    @try {
        titleView = [self valueForKey:@"_titleView"];
    } @catch (__unused NSException *e) {}
    if (titleView && [titleView isKindOfClass:[UIView class]]) {
        titleView.userInteractionEnabled = NO;
        for (UIGestureRecognizer *g in [titleView.gestureRecognizers copy]) {
            [titleView removeGestureRecognizer:g];
        }
    }
}

%end

// 4. Block IGAddAccountManager
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

// 5. Dismiss account sheet view controllers immediately if created
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

// 6. Dismiss switch users view controller immediately if created
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

// 7. Dismiss SSO account picker immediately if created
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

// 8. Block URL navigation to accounts center, add account, switcher, or logout
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

%end // SPKSingleAccountLockHooks

// MARK: - General UIKit Hooks (Always Active)

%group SPKGeneralLockUIHooks

%hook UIViewController

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
    if ([clsName containsString:@"Settings"] || [clsName containsString:@"Settings2"]) {
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
        Class accountSwitcherCls = SPKResolveIGClass(@"IGAccountSwitcher", @"IGAccountSwitcher");
        Class profileTitleCls = SPKResolveIGClass(@"IGProfileTitleViewController", @"IGProfileTitleViewController");
        Class navHeaderCls = SPKResolveIGClass(@"IGProfileNavigationSwift.IGProfileNavigationHeaderView", @"IGProfileNavigationHeaderView");
        Class addManagerCls = SPKResolveIGClass(@"IGAddAccountManager", @"IGAddAccountManager");
        Class addSheetCls = SPKResolveIGClass(@"IGAddAccountSheetViewController", @"IGAddAccountSheetViewController");
        Class switchUsersCls = SPKResolveIGClass(@"IGSwitchUsersViewController", @"_TtC18IGSwitchUsersUI31IGSwitchUsersViewController");
        Class ssoCls = SPKResolveIGClass(@"IGRegistration.IGSSOAccountPickerViewController", @"IGSSOAccountPickerViewController");
        Class urlHandlerCls = SPKResolveIGClass(@"IGURLHandler", @"IGURLHandler");

        SPKLog(@"AccountLock", @"Installing AccountLock hooks: switcher=%@ title=%@ header=%@ add=%@ sheet=%@ switchVC=%@ sso=%@ url=%@",
               accountSwitcherCls ? @"OK" : @"NIL", profileTitleCls ? @"OK" : @"NIL",
               navHeaderCls ? @"OK" : @"NIL", addManagerCls ? @"OK" : @"NIL",
               addSheetCls ? @"OK" : @"NIL", switchUsersCls ? @"OK" : @"NIL",
               ssoCls ? @"OK" : @"NIL", urlHandlerCls ? @"OK" : @"NIL");

        %init(SPKSingleAccountLockHooks,
              IGAccountSwitcher = accountSwitcherCls,
              IGProfileTitleViewController = profileTitleCls,
              IGProfileNavigationHeaderView = navHeaderCls,
              IGAddAccountManager = addManagerCls,
              IGAddAccountSheetViewController = addSheetCls,
              IGSwitchUsersViewController = switchUsersCls,
              IGSSOAccountPickerViewController = ssoCls,
              IGURLHandler = urlHandlerCls);

        %init(SPKGeneralLockUIHooks);
    });
}
