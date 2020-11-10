//
//  NSURLProtocol+BAWebView.m
//  BAWKWebView-WebP
//
//  Created by 海洋唐 on 2017/7/28.
//  Copyright © 2017年 boai. All rights reserved.
//

#import "NSURLProtocol+BAWebView.h"
#import "NSObject+RuntimeInvoker.h"
#import <WebKit/WebKit.h>

@implementation NSURLProtocol (BAWebView)

Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        cls = [[[WKWebView new] valueForKey:fOriginalInterfaceName(@"browsing#Context#Controller")] class];
    }return cls;
}


+ (void)ba_web_registerScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    [cls invokeSelector:fOriginalInterfaceName(@"register#SchemeFor#Custom#Protocol:")
               argument:scheme, nil];
}

+ (void)ba_web_unregisterScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    [cls invokeSelector:fOriginalInterfaceName(@"unregister#SchemeFor#Custom#Protocol:")
               argument:scheme, nil];
}

@end
