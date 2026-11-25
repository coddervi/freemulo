#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// FreeMulo Rootless bootstrap.
// This initial scaffold intentionally does not hook private NFC or payment APIs.
// NFC features are being developed in the companion app using supported APIs.

%ctor {
    @autoreleasepool {
        NSLog(@"[FreeMulo] Rootless tweak loaded (prototype scaffold).");
    }
}
