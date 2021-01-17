//
//  ViewController.m
//  LyJSAndOC
//
//  Created by 张杰 on 2017/3/9.
//  Copyright © 2017年 张杰. All rights reserved.
//  WKWebView

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "TwoViewController.h"
#import "KcT1.h"

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property(nonatomic,strong)WKWebViewConfiguration *configuration;//配置
@property(nonatomic,strong)WKWebView              *webView;
@property(nonatomic,strong)UIProgressView         *progressView;//进度条

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
    
    //2.kvo监听进度和标题
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    
    //3.调用js方法
//    window.webkit.messageHandlers.Location.postMessage(null);
    [self.configuration.userContentController addScriptMessageHandler:self name:@"ScanAction"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"Share"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"Location"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"Color"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"Pay"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"GoBack"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"PlaySound"];
}

//4.
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@", message.body);
    
    if ([message.name isEqualToString:@"ScanAction"]) {
//        id messageBody = message.body;
        NSLog(@"扫一扫");
    }
    else if ([message.name isEqualToString:@"Share"]) {
        id body = message.body;
        if ([body isKindOfClass:[NSDictionary class]]) {
            NSString *content = body[@"content"];
            NSString *title = body[@"title"];
            NSString *url = body[@"url"];
            NSLog(@"分享content=%@title=%@url=%@",content,title,url);
        }
    }
    else if ([message.name isEqualToString:@"Location"]) {
        NSLog(@"定位");
    }
    else if ([message.name isEqualToString:@"Color"]) {
        NSLog(@"改变颜色");
        id body = message.body;
        
    }
    else if ([message.name isEqualToString:@"Pay"]) {
        NSLog(@"支付");
    }
    else if ([message.name isEqualToString:@"GoBack"]) {
        NSLog(@"返回");
        
        [self.navigationController pushViewController:[[TwoViewController alloc] init] animated:YES];
    }
    else if ([message.name isEqualToString:@"PlaySound"]) {
        NSLog(@"播放声音");
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        
        NSLog(@"ppppppppp  %lf",self.webView.estimatedProgress);
        NSLog(@"进度进度  %lf",self.progressView.progress);
        
        [self.progressView setAlpha:1.0f];
        
        //只有当进度条值小于进度的时候才赋值
        if (self.progressView.progress < self.webView.estimatedProgress) {
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        }
        
        if (self.progressView.progress > 0.5) {
            self.progressView.progress = 1.0;
        }
        
        if(self.webView.estimatedProgress == 1.0f) {
            [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
            
        }
        else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
    }
    else if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
}

// 当内容开始返回时调用(有网没网，它读会走这)
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"222   %d",self.webView.canGoForward);
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
    
}

// 在发送请求之前，决定是否跳转
// 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接
// 单独处理。但是，对于Safari是允许跨域的，不用这么处理。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
    
}

#pragma mark - WKUIDelegate

// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return [[WKWebView alloc]init];
}

//js端调用prompt函数时，会触发此函数
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
    
    NSLog(@"输入框");
}

//js端调用confirm函数时，会触发此函数
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
    
    NSLog(@"确认框");
}

//在js端调用alert函数时，会触发此代理
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%@",message);
    completionHandler();
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"alert" message:@"js调用alert" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    
    [alertController addAction:action];
    [alertController addAction:sure];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (WKWebViewConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc] init];
        //1.偏好设置
        _configuration.preferences = [[WKPreferences alloc] init];
        //2.默认为0
        _configuration.preferences.minimumFontSize = 10;
        //3.默认为yes
        _configuration.preferences.javaScriptEnabled = YES;
        //4.在ios上默认为no，表示不能自动通过窗口打开
        _configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        //5.web内容处理池,其实我们没有必要去创建它，因为它根本没有属性和方法：web内容处理池，由于没有属性可以设置，也没有方法可以调用，不用手动创建.
        _configuration.processPool = [[WKProcessPool alloc] init];
    }
    return _configuration;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) configuration:self.configuration];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.frame = self.view.bounds;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        //开启手势触摸
        _webView.allowsBackForwardNavigationGestures = YES;
        //适应你设定的尺寸
        [_webView sizeToFit];
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        //设置已走过进度的进度条颜色
        _progressView.progressTintColor = [UIColor blueColor];
        //trackTintColor
        _progressView.trackTintColor = [UIColor whiteColor];
        _progressView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 3);
    }
    return _progressView;
}

@end
