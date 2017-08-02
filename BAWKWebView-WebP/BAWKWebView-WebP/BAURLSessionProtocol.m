//
//  BAURLSessionProtocol.m
//  BAWKWebView-WebP
//
//  Created by 海洋唐 on 2017/7/28.
//  Copyright © 2017年 boai. All rights reserved.
//

#import "BAURLSessionProtocol.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIImage+WebP.h>

static NSString *URLProtocolHandledKey = @"URLHasHandle";

@interface BAURLSessionProtocol()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic,strong) NSURLSession *session;
@property (strong, nonatomic) NSMutableData *imageData;
@property (nonatomic) BOOL beginAppendData;

@end

@implementation BAURLSessionProtocol

#pragma mark 初始化请求
/**
 判断是否启用SD_WEBP 并且图片格式为webp 如果为YES 则标记请求需要自行处理并且防止无限循环 为NO则不处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
           [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)) &&
        ([[request.URL absoluteString] hasSuffix:@"webp"]))
    {
        // 看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

#pragma mark 通信协议内容实现
// 开始
- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    [[self.session dataTaskWithRequest:mutableReqeust] resume];
    
}

// 停止
- (void)stopLoading
{
    [self.session invalidateAndCancel];
}

#pragma mark - dataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest *    redirectRequest;
    
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:URLProtocolHandledKey inRequest:redirectRequest];
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.session invalidateAndCancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
    self.imageData = [[NSMutableData alloc] initWithCapacity:expected];
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    if ([dataTask.currentRequest.URL.absoluteString hasSuffix:@"webp"]) {
        self.beginAppendData = YES;
        [self.imageData appendData:data];
    }
    if (!_beginAppendData) {
        [self.client URLProtocol:self didLoadData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    
    if (error) {
        
        [self.client URLProtocol:self didFailWithError:error];
    }else{
        if ([task.currentRequest.URL.absoluteString hasSuffix:@"webp"]) {
            // 如果判断是需要处理的webp图片，就对图片进行转换
            NSLog(@"webp---%@",task.currentRequest.URL);
            UIImage *imgData = [UIImage sd_imageWithWebPData:self.imageData];
            NSData *transData = UIImageJPEGRepresentation(imgData, 0.8f);
            self.beginAppendData = NO;
            self.imageData = nil;
            [self.client URLProtocol:self didLoadData:transData];
        }
        [self.client URLProtocolDidFinishLoading:self];
    }
    
}


@end
