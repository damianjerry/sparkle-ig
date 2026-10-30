#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../../InstagramHeaders.h"
#import "../../Utils.h"
#import "../ActionButton/ActionButtonCore.h"
#import "SPKAccountManager.h"

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

@interface IGAddAccountManager : NSObject
- (void)presentAddAccountSheetWithPresentingViewController:(id)vc registrationBlock:(id)reg loginBlock:(id)log;
- (void)showAddAcountUIAnimated:(BOOL)a1 addAccountSheetPresentingVC:(id)a2 entryPoint:(unsigned long long)a3 logger:(id)a4 multipleAccountHandler:(id)a5 accountSwitcher:(id)a6 cancelSwitchDestinationAppSurface:(id)a7;
@end

@interface IGAddAccountSheetViewController : UIViewController
@end

@interface IGSwitchUsersController : UIViewController
@end

@interface IGSettingsCategoriesViewController : UIViewController
- (void)_tableView:(id)tableView didSelectAddAccountRow:(long long)row;
- (void)_tableView:(id)tableView didSelectSessionRowAtIndexPath:(NSIndexPath *)indexPath;
@end

%group SPKSingleAccountLockHooks

// 1. Block IGAccountSwitcher completely
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

%end

// 2. Block username tap on profile header (IGProfileTitleViewController)
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

// 3. Block profile navigation header title view interactions
%hook IGProfileNavigationHeaderView

- (void)layoutSubviews {
    %orig;
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

// 5. Dismiss IGAddAccountSheetViewController immediately if created
%hook IGAddAccountSheetViewController

- (void)viewDidLoad {
    %orig;
    self.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [self dismissViewControllerAnimated:NO completion:nil];
}

%end

// 6. Dismiss IGSwitchUsersController immediately if created
%hook IGSwitchUsersController

- (void)viewDidLoad {
    %orig;
    self.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [self dismissViewControllerAnimated:NO completion:nil];
}

%end

// 7. Block "Add account" / "Switch account" in native Instagram settings
%hook IGSettingsCategoriesViewController

- (void)_tableView:(id)tableView didSelectAddAccountRow:(long long)row {
    SPKLog(@"AccountLock", @"[Single Account Lock] Blocked settings didSelectAddAccountRow");
    return;
}

- (void)_tableView:(id)tableView didSelectSessionRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *text = cell.textLabel.text.lowercaseString ?: @"";
    if ([text containsString:@"add account"] ||
        [text containsString:@"switch account"] ||
        [text containsString:@"add or switch"] ||
        [text containsString:@"cont"] ||
        [text containsString:@"switch"]) {
        SPKLog(@"AccountLock", @"[Single Account Lock] Blocked settings session row: %@", text);
        return;
    }
    %orig;
}

%end

// 8. Global safety guard: intercept any presentation of account switching/adding controllers
%hook UIViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    NSString *className = NSStringFromClass([viewControllerToPresent class]);
    if ([className containsString:@"SwitchUser"] ||
        [className containsString:@"AddAccount"] ||
        [className containsString:@"AccountSwitcher"]) {
        SPKLog(@"AccountLock", @"[Single Account Lock] Intercepted and blocked modal presentation of %@", className);
        if (completion) {
            completion();
        }
        return;
    }
    %orig;
}

%end

%end // SPKSingleAccountLockHooks

extern "C" void SPKInstallAccountSwitchHooksIfNeeded(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class accountSwitcherCls = SPKResolveIGClass(@"IGAccountSwitcher", @"IGAccountSwitcher");
        Class profileTitleCls = SPKResolveIGClass(@"IGProfileTitleViewController", @"IGProfileTitleViewController");
        Class navHeaderCls = SPKResolveIGClass(@"IGProfileNavigationSwift.IGProfileNavigationHeaderView", @"IGProfileNavigationHeaderView");
        Class addManagerCls = SPKResolveIGClass(@"IGAddAccountManager", @"IGAddAccountManager");
        Class addSheetCls = SPKResolveIGClass(@"IGAddAccountSheetViewController", @"IGAddAccountSheetViewController");
        Class switchUsersCls = SPKResolveIGClass(@"IGSwitchUsersController", @"IGSwitchUsersController");
        Class settingsCatCls = SPKResolveIGClass(@"IGSettingsCategoriesViewController", @"IGSettingsCategoriesViewController");

        %init(SPKSingleAccountLockHooks,
              IGAccountSwitcher = accountSwitcherCls,
              IGProfileTitleViewController = profileTitleCls,
              IGProfileNavigationHeaderView = navHeaderCls,
              IGAddAccountManager = addManagerCls,
              IGAddAccountSheetViewController = addSheetCls,
              IGSwitchUsersController = switchUsersCls,
              IGSettingsCategoriesViewController = settingsCatCls,
              UIViewController = [UIViewController class]);
    });
}
