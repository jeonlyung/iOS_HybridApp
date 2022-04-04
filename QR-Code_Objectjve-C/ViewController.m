#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "ViewClass/ScanViewController.h"
#import "ViewClass/WindowOpenViewController.h"
#import "SafariServices/SafariServices.h"

@interface ViewController ()<WKUIDelegate , WKNavigationDelegate , WKScriptMessageHandler, UIWebViewDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIView *uiWebView;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, assign, getter=isWorking) BOOL localBoolean;

@end

@implementation ViewController
// 지역 변수를 선언합니다.
// 웹뷰의 랜더 속도 및 각종 설정들을 담당하는 클래스입니다.
WKWebViewConfiguration *config;

// 자바스크립트에서 메시지를 받거나 자바스크립트를 실행하는데 필요한 클래스입니다.
WKUserContentController *jsctrl;

   
- (void)viewDidLoad {
    [super viewDidLoad];
    _localBoolean = YES; //개발:YES, 운영:NO

    // WkWebViewConfiguration과 WKUserContentController를 초기화해줍니다.
    config = [[WKWebViewConfiguration alloc]init];
    jsctrl = [[WKUserContentController alloc]init];
    
    // 자바스크립트 -> ios에 사용될 핸들러 이름을 추가
    [jsctrl addScriptMessageHandler:self name:@"goScanQR"];
    [jsctrl addScriptMessageHandler:self name:@"openSafari"];
    [jsctrl addScriptMessageHandler:self name:@"webViewSafari"];
    // WkWebView의 configuration에 스크립트에 대한 설정을 정해줍니다.
    [config setUserContentController:jsctrl];

       
    CGRect frame = [[UIScreen mainScreen]bounds];
    // WkWebView는 IBOutlet으로 제공되지 않아 스토리보드에서 추가할 수 없습니다.
    // 웹뷰의 크기를 정해준 후 초기화하고 본 ViewController의 뷰에 추가합니다.

    self.wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:config];
    
    //userAgent Custom
    NSString *userAgent = [_wkWebView valueForKey:@"userAgent"];
    userAgent = [NSString stringWithFormat:@"%@QR_Code_Scanner", userAgent];
    NSLog(@"userAgent : %@", userAgent);
    
    NSDictionary *dic =@{@"UserAgent": [NSString stringWithFormat:@"%@", userAgent]};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
    self.wkWebView.customUserAgent = userAgent;
    
    
    
    // 웹뷰의 딜리게이트들을 새로 초기화해줍니다.(webView 선언 후에 초기화 시켜줘야됨!)
    [self.wkWebView setUIDelegate:self];
    [self.wkWebView setNavigationDelegate:self];
    [self.view addSubview:self.wkWebView];
    
    if(_localBoolean){//local 파일 불러오기
        NSString* productURL = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www/index.html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:productURL]];

        [self.wkWebView loadRequest:request];
        
    }else{
        _baseUrl = @"http://devhorsepia.intra.kra.co.kr"; //호스피아 개발
        //_baseUrl = @"https://www.horsepia.com"; //호스피아 운영
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_baseUrl]];
        [self.wkWebView loadRequest:request];
    
    }
  
}


// WKScriptMessageHandler에 의해 생성된 delegate 함수입니다.
// 자바스크립트에서 ios에 wekkit핸들러를 통해 함수 호출시(함수에 파라미터 있어야됨)!
//메세지의 name 과 body로 구분해서 어떤 js 함수에서 호출했는지와 데이터를 가져온다.
- (void)userContentController:(WKUserContentController *)userContentController
        didReceiveScriptMessage:(WKScriptMessage *)message{

    NSLog(@"didReceiveScriptMessage !");
    
    if([message.name isEqualToString:@"test"]){
        NSLog(@"test !");
    } else if([message.name isEqualToString:@"goScanQR"]){
        NSLog(@"goScanQR !");
        NSString *str = [message body]; //넘어온 데이터 : [message body]
        NSLog(@"str : %@", str);
        
        /*
        //1차 시도(Navigation View 호출) --> 실패
        ScanController *scanController = [ScanController new];
        [self.navigationController pushViewController:scanController animated:YES];
        */
        
        /*
         //2차시도(seque)
        [self performSegueWithIdentifier:@"ScanController" sender:self];
        */
        
        
        /*
        //3차시도(View 띄우기) --> 스토리보드 에러 발생 --> Main thread 에 비동기식 Thread[dispatch_async(dispatch_get_main_queue(), ^{});] 접근 추가 해줘야 가능
        // 개별 뷰 호출 방식으로 변경
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *navi = [storyboard instantiateViewControllerWithIdentifier:@"ScanController"];
        [self presentViewController:navi animated:true completion:nil];
        */
        
        //개별 뷰 호출 방식
        ScanViewController *sv = [[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil];
        [sv setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
        
        //callback함수 셋팅
        sv.callback = ^(NSString *result) {
            NSLog(@"callback Result : %@", result);
            NSString *javaScript = [NSString stringWithFormat:@"SuccessScanQR('%@');", result];
            [self.wkWebView evaluateJavaScript:javaScript completionHandler:^(NSString *result, NSError *error)
            {
                NSLog(@"javaScript : %@", javaScript);
            }];
        };
        
        sv.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:sv animated:NO completion:nil];

    } else if([message.name isEqualToString:@"openSafari"]){//앱 외부에서 사파리 브라우저로 호출하기
        NSLog(@"openSafari Navtive Call Success");
        NSURL *URL = [message body];
        NSLog(@"ExternalURL : %@", URL);
        //URL = [URL absoluteString];
        
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL] options:@{} completionHandler:nil];

    }else if([message.name isEqualToString:@"webViewSafari"]){//앱 내에서 사파리 브라우저로 호출하기
        //외부 브라우저로 호출할경우 앱스토어 배포시 리젝 당함(SFSafriViewController 사용)
        NSLog(@"webViewSafari Navtive Call Success");
        NSURL *url = [message body];
        NSLog(@"webViewSafari : %@", url);

        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
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
 

//javscript alert호출 안됨(밑에 추가해줘야 가능)
//WkWebView Alert Custom
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
        initiatedByFrame:(WKFrameInfo *)frame
        completionHandler:(void (^)(void))completionHandler {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"알림" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { completionHandler();
            }]];
            [self presentViewController:alertController animated:YES completion:^{}];
    
}
//WkWebView Confirm Custom
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
        initiatedByFrame:(WKFrameInfo *)frame
        completionHandler:(void (^)(BOOL result))completionHandler {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"알림" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                completionHandler(YES);
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                completionHandler(NO);
            }]];
            [self presentViewController:alertController animated:YES completion:nil];

    
}

//WkWebView Prompt Custom
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
        defaultText:(nullable NSString *)defaultText
        initiatedByFrame:(WKFrameInfo *)frame
        completionHandler:(void (^)(NSString * __nullable result))completionHandler {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = defaultText;
            }];

            [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
                completionHandler(input);
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                completionHandler(nil);
            }]];

            [self presentViewController:alertController animated:YES completion:nil];

}

//WkWebView window.open 새창 열기 이벤트 감지
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    
    if (!navigationAction.targetFrame.isMainFrame) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            NSLog(@"window.open URL : %@", navigationAction.request.URL);
            
            //개별 뷰 호출 방식
            WindowOpenViewController *ov = [[WindowOpenViewController alloc] initWithNibName:@"WindowOpenViewController" bundle:nil];
            [ov setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
            ov.requestURL = navigationAction.request.URL;
            [self presentViewController:ov animated:NO completion:nil];

        }
    }
    return nil;
}
@end
