//
//  NSURLProtocol+BAWebView.h
//  BAWKWebView-WebP
//
//  Created by 海洋唐 on 2017/7/28.
//  Copyright © 2017年 boai. All rights reserved.
//

/****
 NSURLProtocol, UIWebView 直接就可以支持,但是WKWebView是不支持的,如何让WKWebView也支持NSURLProtocol
 **/

#import <Foundation/Foundation.h>

@interface NSURLProtocol (BAWebView)


/**
 NSURLProtocol registerScheme

 @param scheme 【http/https】
 */
+ (void)ba_web_registerScheme:(NSString*)scheme;


/**
 NSURLProtocol webView销毁的时候注销Scheme

 @param scheme 【http/https】
 */
+ (void)ba_web_unregisterScheme:(NSString*)scheme;

@end
