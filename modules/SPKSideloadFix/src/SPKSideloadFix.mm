#import "Header.h"
#import <objc/runtime.h>

static BOOL (*orig_NSCFString_hasPrefix)(id self, SEL _cmd, NSString *str) = NULL;
static BOOL swizzled_hasPrefix(id self, SEL _cmd, NSString *str) {
	if (!str || ![str isKindOfClass:[NSString class]]) {
		return NO;
	}
	return orig_NSCFString_hasPrefix ? orig_NSCFString_hasPrefix(self, _cmd, str) : NO;
}

static void installHasPrefixGuard(void) {
	Class cls = objc_getClass("__NSCFString");
	if (cls) {
		Method m = class_getInstanceMethod(cls, @selector(hasPrefix:));
		if (m) {
			orig_NSCFString_hasPrefix = (BOOL (*)(id, SEL, NSString *))method_getImplementation(m);
			method_setImplementation(m, (IMP)swizzled_hasPrefix);
		}
	}
	Class baseCls = objc_getClass("NSString");
	if (baseCls && !orig_NSCFString_hasPrefix) {
		Method m = class_getInstanceMethod(baseCls, @selector(hasPrefix:));
		if (m) {
			orig_NSCFString_hasPrefix = (BOOL (*)(id, SEL, NSString *))method_getImplementation(m);
			method_setImplementation(m, (IMP)swizzled_hasPrefix);
		}
	}
}

__attribute__((constructor)) static void init() {
	installHasPrefixGuard();
	rebindSecFuncs();
}
