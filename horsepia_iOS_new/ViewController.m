//
//  ViewController.m
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/01/14.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>


@interface ViewController ()

//@property (weak, nonatomic) IBOutlet WKWebView *wkWebView;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIView *uiWebView;


@property (nonatomic, strong) NSString *baseUrl;
 

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _baseUrl = @"https://www.horsepia.com"; //운영
    //_baseUrl = @"m.kra.co.kr";
    //_baseUrl = @"http://www.devhorespia.intra.kra.co.kr"; //개발
    
    
    

    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
       [self.view addSubview:self.wkWebView];
       
       NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_baseUrl]];
       [self.wkWebView loadRequest:request];
}


- (void)moveToHome {
   
}

@end
