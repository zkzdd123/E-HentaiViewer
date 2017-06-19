//
//  QJWebViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/23.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJWebViewController.h"
#import "QJHenTaiParser.h"
#import "NJKWebViewProgress.h"

@interface QJWebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)backAction:(UIBarButtonItem *)sender;
- (IBAction)refreshAction:(UIBarButtonItem *)sender;

@end

@implementation QJWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:FORUMS_URL]]];
    self.webView.delegate = self.progressProxy;
}

- (IBAction)backAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refreshAction:(UIBarButtonItem *)sender {
    [self.webView reload];
}

#pragma mark -NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:NO];
}

#pragma mark -UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NetworkShow();
    self.progressView.hidden = NO;
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLogFunc();
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NetworkHidden();
    self.progressView.hidden = YES;
    if ([[QJHenTaiParser parser] checkCookie]) {
        NSString *js = @"document.documentElement.innerHTML";
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:js];
        if ([[QJHenTaiParser parser] saveUserNameWithString:html isWeb:YES]) {
            ToastSuccess(nil, @"登陆成功!");
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTI object:nil];
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            ToastWarning(nil, @"可能网站结构变了,没获取到你的名字呢,但是登陆成功了哦~");
        }
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLogFunc();
}

#pragma mark -懒加载
- (NJKWebViewProgress *)progressProxy {
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
    }
    return _progressProxy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
