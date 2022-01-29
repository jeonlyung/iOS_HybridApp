//
//  ViewController.m
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/01/14.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>


@interface ViewController ()<WKUIDelegate , WKNavigationDelegate , WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIView *uiWebView;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, assign, getter=isWorking) BOOL devBoolean;
//웹뷰 컨테이너
@property (strong, nonatomic) IBOutlet UIView *webViewContainer;

@end

@implementation ViewController
// 지역 변수를 선언합니다.
// 웹뷰의 랜더 속도 및 각종 설정들을 담당하는 클래스입니다.
WKWebViewConfiguration *config;

// 자바스크립트에서 메시지를 받거나 자바스크립트를 실행하는데 필요한 클래스입니다.
WKUserContentController *jsctrl;

   
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _devBoolean = YES; //개발:YES, 운영:NO
    
    if(_devBoolean){//local 파일 불러오기
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.wkWebView loadRequest:request];
        
    }else{
        _baseUrl = @"http://devhorsepia.intra.kra.co.kr"; //호스피아 개발
        //_baseUrl = @"https://www.horsepia.com"; //호스피아 운영

        // WkWebViewConfiguration과 WKUserContentController를 초기화해줍니다.
        config = [[WKWebViewConfiguration alloc]init];
        jsctrl = [[WKUserContentController alloc]init];
           
        // 자바스크립트 -> ios에 사용될 핸들러 이름을 추가해줍니다.
        // 본 글에서는 핸들러 및 프로토콜을 ioscall로 통일합니다.
        [jsctrl addScriptMessageHandler:self name:@"goScanQR"];
        // WkWebView의 configuration에 스크립트에 대한 설정을 정해줍니다.
        [config setUserContentController:jsctrl];
           
        // 웹뷰의 딜리게이트들을 새로 초기화해줍니다.
        [self.wkWebView setUIDelegate:self];
        [self.wkWebView setNavigationDelegate:self];
           
        CGRect frame = [[UIScreen mainScreen]bounds];
        
        
        // WkWebView는 IBOutlet으로 제공되지 않아 스토리보드에서 추가할 수 없습니다.
        // 웹뷰의 크기를 정해준 후 초기화하고 본 ViewController의 뷰에 추가합니다.

        self.wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:config];
        [self.wkWebView setNavigationDelegate:self];
        [self.view addSubview:self.wkWebView];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_baseUrl]];
        [self.wkWebView loadRequest:request];
    }
  
}


// WKScriptMessageHandler에 의해 생성된 delegate 함수입니다.
// 자바스크립트에서 ios에 wekkit핸들러를 통해 함수 호출시
//메세지의 name 과 body로 구분해서 어떤 js 함수에서 호출했는지와 데이터를 가져온다.
- (void)userContentController:(WKUserContentController *)userContentController
        didReceiveScriptMessage:(WKScriptMessage *)message{

    NSLog(@"didReceiveScriptMessage !");
    
    if([message.name isEqualToString:@"test"]){
        NSLog(@"test !");
    } else if([message.name isEqualToString:@"goScanQR"]){
        NSLog(@"goScanQR !");
        NSString *str = [message body];
        NSLog(@"%%@ : %@", str);
    }
}



//WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"1. didCommitNavigation");
}
 
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"2. didFinishNavigation");
}
 
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"3. didFailNavigation");
}
 

@end
