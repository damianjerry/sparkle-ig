#import "Header.h"
#import <dlfcn.h>
#import "fishhook.h"

static NSURL *redirectedAppGroupURL(NSString *groupIdentifier) {
	if (!groupIdentifier || ![groupIdentifier isKindOfClass:[NSString class]]) return nil;
	if (![groupIdentifier hasPrefix:@"group"]) return nil;

	if (NSURL *appGroupURL = getAppGroupPathIfExists()) {
		return [appGroupURL URLByAppendingPathComponent:groupIdentifier];
	}

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths lastObject];
	if (!documentsPath) return nil;

	NSString *fakePath = [documentsPath stringByAppendingPathComponent:groupIdentifier];
	return [NSURL fileURLWithPath:fakePath];
}

static NSURL *(*orig_IGAppGroupContainerURL)(void) = NULL;
static NSURL *hooked_IGAppGroupContainerURL(void) {
	NSURL *res = orig_IGAppGroupContainerURL ? orig_IGAppGroupContainerURL() : nil;
	if (!res) {
		res = redirectedAppGroupURL(@"group.com.burbn.instagram");
	}
	return res;
}

static NSURL *(*orig_IGAppGroupContainerURLWithAppType)(NSInteger) = NULL;
static NSURL *hooked_IGAppGroupContainerURLWithAppType(NSInteger type) {
	NSURL *res = orig_IGAppGroupContainerURLWithAppType ? orig_IGAppGroupContainerURLWithAppType(type) : nil;
	if (!res) {
		res = redirectedAppGroupURL(@"group.com.burbn.instagram");
	}
	return res;
}

%hook IGProductSaveStatusStore

- (void)prepareIfNeeded {
	@try {
		%orig;
	} @catch (NSException *e) {
		SPKSideloadLog(@"Caught exception in prepareIfNeeded: %@", e);
	}
}

%end

%hook CKContainer
- (id)_setupWithContainerID:(id)a options:(id)b { return nil; }
- (id)_initWithContainerIdentifier:(id)a { return nil; }
%end

%hook CKEntitlements
- (id)initWithEntitlementsDict:(NSDictionary *)entitlements {
	NSMutableDictionary *mutEntitlements = [entitlements mutableCopy];
	[mutEntitlements removeObjectForKey:@"com.apple.developer.icloud-container-environment"];
	[mutEntitlements removeObjectForKey:@"com.apple.developer.icloud-services"];
	return %orig([mutEntitlements copy]);  // why? whatever
}
%end

%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
	if (NSURL *fakeAppGroupURL = redirectedAppGroupURL(groupIdentifier)) {
		createDirectoryIfNotExists(fakeAppGroupURL.path);
		return fakeAppGroupURL;
	}

	return %orig(groupIdentifier);
}
%end

BOOL isAppExtensionProcess(void) {
	static BOOL cached = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cached = ([[NSBundle mainBundle] infoDictionary][@"NSExtension"] != nil);
	});
	return cached;
}

%hook NSUserDefaults
- (id)_initWithSuiteName:(NSString *)suiteName container:(NSURL *)container {
	if (!isAppExtensionProcess()) {
		return %orig(suiteName, container);
	}

	if (![suiteName hasPrefix:@"group"]) {
		return %orig(suiteName, container);
	}

	if (NSURL *customContainerURL = redirectedAppGroupURL(suiteName)) {
		createDirectoryIfNotExists(customContainerURL.path);
		SPKSideloadLog(@"Redirecting extension defaults suite=%@ to app group container", suiteName);
		return %orig(suiteName, customContainerURL);
	}

	SPKSideloadLog(@"Unable to construct app group container for suite=%@; using original container", suiteName);
	return %orig(suiteName, container);
}
%end

%ctor {
	void *sym = dlsym(RTLD_DEFAULT, "IGAppGroupContainerURL");
	if (sym) {
		orig_IGAppGroupContainerURL = (NSURL *(*)(void))sym;
	}
	void *symType = dlsym(RTLD_DEFAULT, "IGAppGroupContainerURLWithAppType");
	if (symType) {
		orig_IGAppGroupContainerURLWithAppType = (NSURL *(*)(NSInteger))symType;
	}
	struct rebinding appGroupRebinds[2] = {
		{"IGAppGroupContainerURL", (void *)hooked_IGAppGroupContainerURL, NULL},
		{"IGAppGroupContainerURLWithAppType", (void *)hooked_IGAppGroupContainerURLWithAppType, NULL}
	};
	rebind_symbols(appGroupRebinds, 2);
}
