//
//  BAWebpController.m
//  BAWKWebView-WebP
//
//  Created by 海洋唐 on 2017/8/2.
//  Copyright © 2017年 boai. All rights reserved.
//


/*!
 *  获取屏幕宽度和高度
 */
#define BAKit_SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define BAKit_SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#import "BAWebpController.h"
#import <WebKit/WebKit.h>
#import "BAWKWebView_WebP.h"

@interface BAWebpController ()

@property (nonatomic,strong)WKWebView *wkWebview;

@end

@implementation BAWebpController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupUI];
}

- (void)setupUI {
    self.wkWebview.hidden = NO;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self ba_registerURLProtocol];
    [self.view addSubview:self.wkWebview];
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.wkWebview.frame = CGRectMake(0, 0, BAKit_SCREEN_WIDTH, BAKit_SCREEN_HEIGHT);
}

#pragma mark - 注册自定义 NSURLProtocol
BOOL beforeiOS(CGFloat aVersion) {
    return UIDevice.currentDevice.systemVersion.floatValue < aVersion;
}


- (void)ba_registerURLProtocol {
    // 新版WebKit内核已经支持webp
    if (beforeiOS(14)) {
        [NSURLProtocol registerClass:NSClassFromString(@"BAURLSessionProtocol")];
        // 注册registerScheme使得WKWebView支持NSURLProtocol
        [NSURLProtocol ba_web_registerScheme:@"http"];
        [NSURLProtocol ba_web_registerScheme:@"https"];
    }
}

- (void)dealloc{
    if (beforeiOS(14)) {
        [NSURLProtocol unregisterClass:NSClassFromString(@"BAURLSessionProtocol")];
        // 移除 registerScheme
        [NSURLProtocol ba_web_unregisterScheme:@"http"];
        [NSURLProtocol ba_web_unregisterScheme:@"https"];
    }
}

- (WKWebView *)wkWebview {
    if (!_wkWebview) {
        _wkWebview = [[WKWebView alloc]initWithFrame:CGRectZero];
    } return _wkWebview;
}

@end
