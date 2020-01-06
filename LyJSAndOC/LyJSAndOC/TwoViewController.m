//
//  TwoViewController.m
//  LyJSAndOC
//
//  Created by 张杰 on 2017/3/9.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "TwoViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJS <JSExport>

// PropertyName: html方法名, Selector: html方法名对应的oc方法名
JSExportAs
(calculateForJS,//这个方法是html里面的
  -(void)dealWithCalculateWithNumber:(NSNumber *)number
 );

JSExportAs
(pushViewControllerTitle,
 - (void)pushToOtherController:(NSString *)view title:(NSString *)title
 );

@end

@interface TwoViewController () <UIWebViewDelegate,TestJS>

@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)JSContext *context;
@property(nonatomic,strong)UIView    *back;
@property(nonatomic,strong)UIAlertController *alertController;

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.webView];
//    self.title = @"UIWebView";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSCallOC.html" ofType:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 以 html title 设置 导航栏 title
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 禁用 页面元素选择
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用 长按弹出ActionSheet
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    //获取H5中的JS上下文,这个固定@"documentView.webView.mainFrame.javaScriptContext"
    self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 打印异常
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"%@", exceptionValue);
    };
    //以 JSExport 协议关联 native 的方法
    /* <input type="button" value="计算阶乘" onclick="native.calculateForJS(input.value);" />
     1.设置protocol
         @protocol TestJS <JSExport>
         
         JSExportAs
         (calculateForJS,//这个方法是html里面的
         -(void)dealWithCalculateWithNumber:(NSNumber *)number
         );
         
         JSExportAs(<#PropertyName#>, <#Selector#>)
         
         @end
     2.self成为delegate
       self.context[@"native"] = self;
     3.实现delegate中的方法
       -(void)dealWithCalculateWithNumber:(NSNumber *)number
     4.把值传递回html
       [self.context[@"showResult"] callWithArguments:@[result]];
     */
    self.context[@"native"] = self;
    
    //2.测试logo
    /*1.native.calculateForJS这种类型的就需要定义方法 2.log这种类型的直接使用block就行
    <input type="button" value="计算阶乘" onclick="native.calculateForJS(input.value);" />
    <input type="button" value="测试log" onclick="log('测试');" />
     */
    self.context[@"log"] = ^(NSString *value) {
        
    };
    
    //3.alert
    __weak typeof(self) weakSelf = self;
    self.context[@"alert"] = ^(NSString *value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [strongSelf.alertController addAction:action];
        [strongSelf presentViewController:strongSelf.alertController animated:YES completion:nil];
    };
    
    //4.addSubView
//    __weak typeof(self) weakSelf = self;
    self.context[@"addSubView"] = ^(NSString *value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.webView addSubview:strongSelf.back];
    };
}

///**
// *  网页加载完毕的时候调用
// */
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    // 跳到id对应的网页标签
//    
//    // 1.拼接Javacript代码
//    NSString *js = [NSString stringWithFormat:@"window.location.href = '#%@';", self.html.ID];
//    // 2.执行JavaScript代码
//    [webView stringByEvaluatingJavaScriptFromString:js];
//}

#pragma mark - JSExport 协议关联 native 的方法的回调
-(void)dealWithCalculateWithNumber:(NSNumber *)number {
    NSNumber *result = [self calculateFactorialOfNumber:number];
    
    // showResult也是html里面定义的
    [self.context[@"showResult"] callWithArguments:@[result]];
}

//计算
- (NSNumber *)calculateFactorialOfNumber:(NSNumber *)number
{
    NSInteger i = [number integerValue];
    if (i < 0)
    {
        return [NSNumber numberWithInteger:0];
    }
    if (i == 0)
    {
        return [NSNumber numberWithInteger:1];
    }
    
    NSInteger r = (i * [(NSNumber *)[self calculateFactorialOfNumber:[NSNumber numberWithInteger:(i - 1)]] integerValue]);
    
    return [NSNumber numberWithInteger:r];
}

/*html页面里的
 
 <a id="push" href="#" onclick="native.pushViewControllerTitle('SecondViewController','secondPushedFromJS');">
 push to second ViewController
 
 */
- (void)pushToOtherController:(NSString *)view title:(NSString *)title
{
    NSLog(@"push");
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [_webView sizeToFit];
        _webView.delegate = self;
        //自动检测电话号码，网址，邮件地址
        _webView.dataDetectorTypes = UIDataDetectorTypeAll;
        //缩放网页
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

- (UIView *)back
{
    if (!_back) {
        _back = [[UIView alloc] init];
        _back.backgroundColor = [UIColor greenColor];
        _back.frame = CGRectMake(0, 400, 50, 50);
    }
    return _back;
}

- (UIAlertController *)alertController
{
    if (!_alertController) {
        _alertController = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleAlert];
    }
    return _alertController;
}

@end
