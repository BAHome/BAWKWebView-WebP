Pod::Spec.new do |s|
    s.name         = 'BAWKWebView-WebP'
    s.version      = '1.0.0'
    s.summary      = 'WKWebView 显示 HTML 中的 GIF 动图、WebP 无损图片，最简单、最方便的接入！（webp 的动态图片显示需要等待后期版本更新），需要 VPN 支持才能下载！'
    s.homepage     = 'https://github.com/BAHome/BAWKWebView-WebP'
    s.license      = 'MIT'
    s.authors      = { 'boai' => 'sunboyan@outlook.com' }
    s.platform     = :ios, '8.0'
    s.source       = { :git => 'https://github.com/BAHome/BAWKWebView-WebP.git', :tag => s.version.to_s }
    s.source_files = 'BAWKWebView-WebP/BAWKWebView-WebP/*.{h,m}'
    s.requires_arc = true
    s.dependency    "SDWebImage/WebP"

end
