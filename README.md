# BAWKWebView-WebP
[![BAHome Team Name](https://img.shields.io/badge/Team-BAHome-brightgreen.svg?style=flat)](https://github.com/BAHome "BAHome Team")
![](https://img.shields.io/badge/platform-iOS-red.svg) ![](https://img.shields.io/badge/language-Objective--C-orange.svg) 
![](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg) 
![](https://img.shields.io/cocoapods/v/BAWKWebView-WebP.svg?style=flat) ![](https://img.shields.io/cocoapods/dt/BAWKWebView-WebP.svg
)  [![](https://img.shields.io/badge/微博-博爱1616-red.svg)](http://weibo.com/538298123)

## 1、功能及简介
* 1、用分类封装 WKWebView，代码无任何侵入更改 <br>
* 2、WKWebView 显示 HTML 中的 GIF 动图、WebP 无损图片，最简单、最方便的接入！
* 3、什么是WebP？简单描述一下，WebP 是 google 创造出的一种图片格式，图片的压缩和解码都由 google 提供的 API 完成（各种语言都有，不过目前好像没看到 js 可以解码 WebP 的），在无损压缩的情况下，比 png 要小28%左右。 现在已经被各大浏览器厂商兼容（如：Chrome，Firefox等），不过苹果的 Safri 还没有完全兼容这种格式，所以如果 UIWebView 里面含有 WebP 的图片的话，就会显示不出来（但是我们可以通过 NSUrlProtocol 来做处理）。如果要在APP中使用得话，我们需要引入 SDWebImage 这个第三方库。<br>
* 4、WebP的劣势：压缩时间长，大概是png的8倍左右（不过一般都是在服务端压缩，客户端解码，所以服务端可以做个预压缩）
解码时间比png长，大概几十毫秒。WebP是节省了流量（图片小），增加了解码时间，换句话说就是：同样的图片，网络越快（图片更小的WebP就没有明显优势），图片越多（WebP要解码），WebP 比 png要慢。
UIWebView，WKWebView都不支持WebP。（UIWebView 可以用NSUrlProtocol来解决，但是WKWebView还没有太完美的办法，谁知道的请告诉我下） 不支持流式解压缩（即图片加载的时候会由模糊慢慢变清晰的过程，WebP貌似不支持这种解压缩方式）
* 5、注意：因为图片的压缩和解码都由 google 提供的 API 完成，所以在使用的时候，记得开启 VPN 再更新 pod ，以免更新 pod 会失败！
 
## 2、图片示例
![BAWKWebView-WebP1](https://github.com/BAHome/BAWKWebView-WebP/blob/master/Images/BAWKWebView-WebP1.png)

## 3、安装、导入示例和源码地址
<!--* 1、pod 导入【最新版本：![](https://img.shields.io/cocoapods/v/BAWKWebView-WebP.svg?style=flat)】： <br>
 `pod 'BAWKWebView-WebP'` <br>
如果发现 `pod search BAWKWebView-WebP` 搜索出来的不是最新版本，需要在终端执行 cd 转换文件路径命令退回到 desktop，然后执行 `pod setup` 命令更新本地spec缓存（可能需要几分钟），然后再搜索就可以了。<br>
具体步骤：
  - pod setup : 初始化
  - pod repo update : 更新仓库
  - pod search BAWKWebView-WebP-->
* 1、文件夹拖入：下载 demo，把 BAWKWebView-WebP 文件夹拖入项目即可，另外需要 pod 导入 `pod 'SDWebImage/WebP'` <br>
* 2、导入头文件：<br>
`  #import "BAWKWebView_WebP.h" `<br>
* 3、项目源码地址：<br>
 OC 版 ：[https://github.com/BAHome/BAWKWebView-WebP](https://github.com/BAHome/BAWKWebView-WebP)<br>
* 5、注意：因为图片的压缩和解码都由 google 提供的 API 完成，所以在使用的时候，记得开启 VPN 再更新 pod ，以免更新 pod 会失败！
 
## 4、BAWKWebView-WebP 的类结构及 demo 示例
![BAWKWebView-WebP](https://github.com/BAHome/BAWKWebView-WebP/blob/master/Images/BAWKWebView-WebP.png)


### demo 示例

`引入SDWebImage来编解码webp`

```C
#import <SDWebImageWebPCoder/SDImageWebPCoder.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	... your code
    
    /// 添加Webp格式解码
    [SDImageCodersManager.sharedManager addCoder:[SDImageWebPCoder sharedCoder]];
    [SDWebImageDownloader.sharedDownloader setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    
    return YES;
}

```

使用

> iOS14发布后，新版WebKit内核已经支持webp，所以只要向下兼容即可

```C

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self ba_registerURLProtocol];
    [self.view addSubview:self.wkWebview];
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

- (void)viewDidLayoutSubviews
{
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

其他示例可下载 demo 查看源码！
```


## 5、更新

 最新更新时间：2020-09-28 【倒叙】<br>
 最新Version：【Version：1.0.3】<br>
 更新内容：<br>
> * 1.0.1、 用分类封装 WKWebView，代码无任何侵入更改
> * 1.0.2、 WKWebView 目前可以兼容 GIF 动图显示，和 webp 的静态图片显示
> * 1.0.3、  已支持webp动图显示
 
## 6、bug 反馈
> 1、开发中遇到 bug，希望小伙伴儿们能够及时反馈与我们 BAHome 团队，我们必定会认真对待每一个问题！ <br>

> 2、以后提需求和 bug 的同学，记得把 git 或者博客链接给我们，我直接超链到你们那里！希望大家积极参与测试！<br> 

## 7、BAHome 团队成员
> 1、QQ 群 
479663605 <br> 
【注意：此群为 2 元 付费群，介意的小伙伴儿勿扰！】<br> 

> 孙博岩 <br> 
QQ：137361770 <br> 
git：[https://github.com/boai](https://github.com/boai) <br>
简书：[http://www.jianshu.com/u/95c9800fdf47](http://www.jianshu.com/u/95c9800fdf47) <br>
微博：[![](https://img.shields.io/badge/微博-博爱1616-red.svg)](http://weibo.com/538298123) <br>

> 马景丽 <br> 
QQ：1253540493 <br> 
git：[https://github.com/MaJingli](https://github.com/MaJingli) <br>

> 陆晓峰 <br> 
QQ：442171865 <br> 
git：[https://github.com/zeR0Lu](https://github.com/zeR0Lu) <br>

> 陈集 <br> 
QQ：3161182978 <br> 
git：[https://github.com/chenjipdc](https://github.com/chenjipdc) <br>
简书：[http://www.jianshu.com/u/90ae559fc21d](http://www.jianshu.com/u/90ae559fc21d)

> 任子丰 <br> 
QQ：459643690 <br> 
git：[https://github.com/renzifeng](https://github.com/renzifeng) <br>

> 吴丰收 <br> 
QQ：498121294 <br> 

> 石少庸 <br> 
QQ：363605775 <br> 
git：[https://github.com/CrazyCoderShi](https://github.com/CrazyCoderShi) <br>
简书：[http://www.jianshu.com/u/0726f4d689a3](http://www.jianshu.com/u/0726f4d689a3)

> 唐海洋 <br> 
QQ：790015339 <br> 
git：[https://github.com/tanghaiyang1992](https://github.com/tanghaiyang1992) <br>
简书：[http://www.jianshu.com/u/b833cfd6bd58](http://www.jianshu.com/u/b833cfd6bd58)


## 8、开发环境 和 支持版本
> 开发使用 最新版本 Xcode，理论上支持 iOS 8 及以上版本，如有版本适配问题，请及时反馈！多谢合作！

## 9、感谢
> 感谢 BAHome 团队成员倾力合作，后期会推出一系列 常用 UI 控件的封装，大家有需求得也可以在 issue 提出，如果合理，我们会尽快推出新版本！<br>

> BAHome 的发展离不开小伙伴儿的信任与推广，再次感谢各位小伙伴儿的支持！

