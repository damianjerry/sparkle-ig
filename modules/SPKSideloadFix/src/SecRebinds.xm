#import <Security/Security.h>
#import <objc/runtime.h>

#import "Header.h"
#import "../fishhook/fishhook.h"

static OSStatus (*origSecItemAdd)(CFDictionaryRef attributes, CFTypeRef *result) = NULL;
static OSStatus (*origSecItemCopyMatching)(CFDictionaryRef query, CFTypeRef *result) = NULL;
static OSStatus (*origSecItemUpdate)(CFDictionaryRef query, CFDictionaryRef attributesToUpdate) = NULL;
static OSStatus (*origSecItemDelete)(CFDictionaryRef query) = NULL;

static CFDictionaryRef SPKSanitizedKeychainDictionary(CFDictionaryRef dict) {
	if (!dict) return NULL;
	NSDictionary *source = (__bridge NSDictionary *)dict;
	if (![source isKindOfClass:[NSDictionary class]]) return NULL;

	NSMutableDictionary *mut = [source mutableCopy];
	// Remove kSecAttrAccessGroup so iOS automatically routes to the application's
	// default private keychain storage without entitlement check failures (-34018).
	[mut removeObjectForKey:(__bridge NSString *)kSecAttrAccessGroup];
	return (CFDictionaryRef)CFBridgingRetain(mut);
}

static OSStatus zxSecItemAdd(CFDictionaryRef attributes, CFTypeRef *result) {
	CFAbsoluteTime startedAt = CFAbsoluteTimeGetCurrent();
	CFDictionaryRef sanitized = SPKSanitizedKeychainDictionary(attributes);
	OSStatus status = origSecItemAdd ? origSecItemAdd(sanitized ?: attributes, result) : errSecUnimplemented;
	if (status == errSecDuplicateItem && sanitized && origSecItemUpdate) {
		NSDictionary *attrsDict = (__bridge NSDictionary *)sanitized;
		NSMutableDictionary *query = [NSMutableDictionary dictionary];
		if (attrsDict[(__bridge NSString *)kSecClass]) query[(__bridge NSString *)kSecClass] = attrsDict[(__bridge NSString *)kSecClass];
		if (attrsDict[(__bridge NSString *)kSecAttrService]) query[(__bridge NSString *)kSecAttrService] = attrsDict[(__bridge NSString *)kSecAttrService];
		if (attrsDict[(__bridge NSString *)kSecAttrAccount]) query[(__bridge NSString *)kSecAttrAccount] = attrsDict[(__bridge NSString *)kSecAttrAccount];

		NSMutableDictionary *updateAttrs = [attrsDict mutableCopy];
		[updateAttrs removeObjectForKey:(__bridge NSString *)kSecClass];
		[updateAttrs removeObjectForKey:(__bridge NSString *)kSecAttrService];
		[updateAttrs removeObjectForKey:(__bridge NSString *)kSecAttrAccount];

		status = origSecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttrs);
		SPKSideloadLog(@"SecItemAdd duplicate handled via update status=%d", (int)status);
	}
	if (sanitized) CFRelease(sanitized);
	SPKSideloadLog(@"SecItemAdd status=%d duration=%.2fms", (int)status, (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0);
	return status;
}

static OSStatus zxSecItemCopyMatching(CFDictionaryRef query, CFTypeRef *result) {
	CFAbsoluteTime startedAt = CFAbsoluteTimeGetCurrent();
	CFDictionaryRef sanitized = SPKSanitizedKeychainDictionary(query);
	OSStatus status = origSecItemCopyMatching ? origSecItemCopyMatching(sanitized ?: query, result) : errSecUnimplemented;
	if (sanitized) CFRelease(sanitized);
	SPKSideloadLog(@"SecItemCopyMatching status=%d duration=%.2fms", (int)status, (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0);
	return status;
}

static OSStatus zxSecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate) {
	CFAbsoluteTime startedAt = CFAbsoluteTimeGetCurrent();
	CFDictionaryRef sanitizedQuery = SPKSanitizedKeychainDictionary(query);
	CFDictionaryRef sanitizedAttrs = SPKSanitizedKeychainDictionary(attributesToUpdate);
	OSStatus status = origSecItemUpdate ? origSecItemUpdate(sanitizedQuery ?: query, sanitizedAttrs ?: attributesToUpdate) : errSecUnimplemented;
	if (sanitizedQuery) CFRelease(sanitizedQuery);
	if (sanitizedAttrs) CFRelease(sanitizedAttrs);
	SPKSideloadLog(@"SecItemUpdate status=%d duration=%.2fms", (int)status, (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0);
	return status;
}

static OSStatus zxSecItemDelete(CFDictionaryRef query) {
	CFAbsoluteTime startedAt = CFAbsoluteTimeGetCurrent();
	CFDictionaryRef sanitized = SPKSanitizedKeychainDictionary(query);
	OSStatus status = origSecItemDelete ? origSecItemDelete(sanitized ?: query) : errSecUnimplemented;
	if (sanitized) CFRelease(sanitized);
	SPKSideloadLog(@"SecItemDelete status=%d duration=%.2fms", (int)status, (CFAbsoluteTimeGetCurrent() - startedAt) * 1000.0);
	return status;
}

void rebindSecFuncs() {
	struct rebinding rebinds[4] = {
		{"SecItemAdd", (void *)zxSecItemAdd, (void **)&origSecItemAdd},
		{"SecItemCopyMatching", (void *)zxSecItemCopyMatching, (void **)&origSecItemCopyMatching},
		{"SecItemUpdate", (void *)zxSecItemUpdate, (void **)&origSecItemUpdate},
		{"SecItemDelete", (void *)zxSecItemDelete, (void **)&origSecItemDelete}
	};
	int res = rebind_symbols(rebinds, 4);
	SPKSideloadLog(@"rebind_symbols result=%d", res);
}
