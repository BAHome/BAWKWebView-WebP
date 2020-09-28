//
//  BAURLSessionProtocol.m
//  BAWKWebView-WebP
//
//  Created by 海洋唐 on 2017/7/28.
//  Copyright © 2017年 boai. All rights reserved.
//

#import "BAURLSessionProtocol.h"
#import <UIKit/UIKit.h>
#import <SDWebImageWebPCoder/UIImage+WebP.h>
#import <SDWebImage/SDWebImage.h>
#import <MobileCoreServices/MobileCoreServices.h>

#if __has_include("webp/decode.h") && __has_include("webp/encode.h") && __has_include("webp/demux.h") && __has_include("webp/mux.h")
#import "webp/decode.h"
#import "webp/encode.h"
#import "webp/demux.h"
#import "webp/mux.h"
#elif __has_include(<libwebp/decode.h>) && __has_include(<libwebp/encode.h>) && __has_include(<libwebp/demux.h>) && __has_include(<libwebp/mux.h>)
#import <libwebp/decode.h>
#import <libwebp/encode.h>
#import <libwebp/demux.h>
#import <libwebp/mux.h>
#else
@import libwebp;
#endif

static NSString *URLProtocolHandledKey = @"URLHasHandle";

@interface BAURLSessionProtocol()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, assign) BOOL beginAppendData;

@end

@implementation BAURLSessionProtocol

#pragma mark 初始化请求
/**
 判断是否启用SD_WEBP 并且图片格式为webp 如果为YES 则标记请求需要自行处理并且防止无限循环 为NO则不处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    BOOL commonScheme = ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
                         [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame);
    NSString * urlString = request.URL.absoluteString.lowercaseString;
    
    /// 只处理webp结尾的请求，避免重定向所有的请求，特别是POST请求（body丢失的问题）
    if (commonScheme && [urlString hasSuffix:@"webp"]) {
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
- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    [[self.session dataTaskWithRequest:mutableReqeust] resume];
}

// 停止
- (void)stopLoading {
    [self.session invalidateAndCancel];
}

#pragma mark - dataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)newRequest
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    NSMutableURLRequest * redirectRequest;
    
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:URLProtocolHandledKey inRequest:redirectRequest];
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.session invalidateAndCancel];
    NSError * error = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:NSUserCancelledError userInfo:nil];
    [[self client] URLProtocol:self didFailWithError:error];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
    self.imageData = [[NSMutableData alloc] initWithCapacity:expected];
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
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
        
    } else if ([task.currentRequest.URL.absoluteString hasSuffix:@"webp"]) {
        // 如果判断是需要处理的webp图片，就对图片进行转换
        NSLog(@"webp---%@",task.currentRequest.URL);
        
        UIImage *imgData = [UIImage sd_imageWithWebPData:self.imageData];
        NSArray * images = imgData.images;

        if (images.count > 1) {
            /// 转换成gif
            NSString * fileName = [[task.currentRequest.URL URLByDeletingPathExtension] lastPathComponent];
            fileName = [NSString stringWithFormat:@"%@.gif",fileName];
            NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            [self handleAnimatedImage:imgData images:images cachePath:cachePath];
        } else {
            [self handleStaticImage:imgData];
        }
        
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)finishWithData:(NSData *)imageData {
    self.beginAppendData = NO;
    self.imageData = nil;
    [self.client URLProtocol:self didLoadData:imageData];
}


- (void)handleStaticImage:(UIImage *)image {
    NSData *transData = UIImageJPEGRepresentation(image, 0.9f);
    [self finishWithData:transData];
}

- (void)handleAnimatedImage:(UIImage *)image
                     images:(NSArray <UIImage *>*)images
                  cachePath:(NSString *)cachePath {
    
    if (image.sd_imageFormat == SDImageFormatGIF) {
        [self finishWithData:[self.imageData copy]];
        return;
    }
    
    NSAssert(image.sd_imageFormat == SDImageFormatWebP, @"请校验格式");
    
    
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = self.imageData.bytes;
    webpData.size = self.imageData.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) {
        [self finishWithData:[self.imageData copy]];
        return;
    }

    // for animated webp image
    WebPIterator iter;
    // libwebp's index start with 1
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        [self finishWithData:[self.imageData copy]];
        return;
    }
    
    /// 获取每一帧的时长
    NSMutableArray<NSNumber *> *frames = [NSMutableArray array];
    do {
        @autoreleasepool {
            int duration = iter.duration;
            if (duration <= 10) {
                duration = 100;
            }
            [frames addObject:[NSNumber numberWithDouble:duration / 1000.0]];
        }
    } while (WebPDemuxNextFrame(&iter));
    WebPDemuxReleaseIterator(&iter);
    WebPDemuxDelete(demuxer);
    
    
    NSURL * cacheURL = [NSURL fileURLWithPath:cachePath];
    
    // 设置gif的彩色空间格式、颜色深度、执行次数
    NSDictionary *gifDic = @{
        (NSString *)kCGImagePropertyGIFLoopCount:@(image.sd_imageLoopCount),
        (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB,
        (NSString *)kCGImagePropertyDepth:@(16)
    };
    NSDictionary *gifProperties = @{(NSString *)kCGImagePropertyGIFDictionary:gifDic};
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)cacheURL,
                                                                        kUTTypeGIF,
                                                                        images.count,
                                                                        NULL);
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    

    NSUInteger repeatCount = images.count / frames.count;
    for (int32_t index = 0; index < frames.count; index ++) {
        /// 对于大部分动图而言，取平均值 image.duration / images.count 即可
        /// 但是也有遇到过 异常卡顿的动图，详细对比后发现，frames只取到了58帧，但是images有348帧
        /// 相当于重复了6次，所以要算出重复的次数，取image的时候跳着取
        ///
        /// 具体原因看 [SDImageCoderHelper animatedImageWithFrames:frames] 方法
        /// 里面有求最大公约数 NSUInteger const gcd = gcdArray(frameCount, durations);
        /// 然后按最大公约数gcd重复插入同一阵gcd次  for (size_t i = 0; i < repeatCount; ++i) {
        /// 正常情况下gcd是1，每1帧插入1次生成新的动图(animatedImage)
        /// 异常情况下gcd会大于1，就会出现同一帧重复插入的情况，会导致总时长累加gcd倍
        /// 出现肉眼可见的卡顿。所以这里要跳着取 (repeatCount = gcd)
        
        NSUInteger imageIndex = index * repeatCount;
        NSNumber * duration = frames[index];
        
        UIImage * frameImage = [images objectAtIndex:imageIndex];
        NSDictionary * gifDict = @{
            (NSString *)kCGImagePropertyGIFDelayTime:duration
        };
        NSDictionary * frameProperties = @{
            (NSString *)kCGImagePropertyGIFDictionary:gifDict
        };
        CGImageDestinationAddImage(destination, frameImage.CGImage, (CFDictionaryRef)frameProperties);
    }

    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    NSData *transData = [NSData dataWithContentsOfFile:cachePath];
    [self finishWithData:transData];
}

@end
