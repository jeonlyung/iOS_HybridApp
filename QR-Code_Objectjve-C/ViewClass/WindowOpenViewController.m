//
//  WindowOpenViewController.m
//  WindowOpen View 화면
//
//  Created by 한국마사회 on 2022/03/02.
//

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "WindowOpenViewController.h"
#import "../ViewController.h"

@interface WindowOpenViewController ()<WKUIDelegate , WKNavigationDelegate , UIWebViewDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIView *uiWebView;

@end

@implementation WindowOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"windowOpenController 진입 : URL[%@]", _requestURL);
    
    
     // 웹뷰의 딜리게이트들을 새로 초기화해줍니다.
     [self.wkWebView setUIDelegate:self];
     [self.wkWebView setNavigationDelegate:self];
        
     CGRect frame = [[UIScreen mainScreen]bounds];
     // WkWebView는 IBOutlet으로 제공되지 않아 스토리보드에서 추가할 수 없습니다.
     // 웹뷰의 크기를 정해준 후 초기화하고 본 ViewController의 뷰에 추가합니다.

     self.wkWebView = [[WKWebView alloc] initWithFrame:frame];
     [self.wkWebView setNavigationDelegate:self];
     [self.view addSubview:self.wkWebView];
 
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_requestURL];
    [self.wkWebView loadRequest:request];
}


@end
