//
//  ScanViewController.m
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/02/16.
//

#import "ScanViewController.h"
#import "../ViewController.h"

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewPlayer;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;


@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isReading = YES;
    _captureSession = nil;
    
    //닫기버튼 이미지로 변경
    UIImage *closeBtnImage = [UIImage imageNamed:@"btn_close"];
    [_closeButton setImage:closeBtnImage forState:UIControlStateNormal];
    [_closeButton setTitle:@" " forState:UIControlStateNormal];
    
    
    if(_isReading) {
        if([self startReading]){
            [_labelStatus setText:@"QR를 화면 안에 맞춰주세요."];
            //[_startButton setTitle:@"스캔 중지" forState:UIControlStateHighlighted];
            
        }
    }
}





- (IBAction)startButton:(id)sender {
    if(_isReading) {
        if([self startReading]){
            //[_labelStatus setText:@"QR를 화면 안에 맞춰주세요."];
           // [_startButton setTitle:@"스캔 중지" forState:UIControlStateHighlighted];
            
        }
    } else {
        [self stopReading];
        //[_labelStatus setText:@"스캔 시작 버튼을 눌러주세요."];
       // [_startButton setTitle:@"스캔 시작" forState:UIControlStateHighlighted];
    }
    _isReading = !_isReading;

}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if(!deviceInput) {
        NSLog(@"Error %@", error.localizedDescription);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession addInput:deviceInput];
    
    AVCaptureMetadataOutput *capturedMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:capturedMetadataOutput];
    
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [capturedMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [capturedMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewPlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    [_videoPreviewPlayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewPlayer setFrame:_viewPreview.layer.bounds];
    
    [_viewPreview.layer addSublayer:_videoPreviewPlayer];
    
    [_captureSession startRunning];
    
    
    return YES;
}


- (void)stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewPlayer removeFromSuperlayer];
}
 

//QR Scan 이후 결과 콜백 함수
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    /*
    if (self.navigationController) {
       [self.navigationController popViewControllerAnimated:YES];
     } else {
       [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
     }
     
     */
    if (metadataObjects != nil && metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            [_labelStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObject stringValue] waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[_startButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
            
            
            //Main Thread Error 해결(2022-02-23)
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"QR Scan Success");
                //Main View 콜백함수 호출
                self.callback([metadataObject stringValue]);
                //SubViewContorller 닫기
                [self dismissViewControllerAnimated:NO completion:nil];
                
                /*
                //스토리보드 뷰 호출 방식
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ViewController *vc = [storyboard instantiateInitialViewController];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                
                vc.QRresultValue = [metadataObject stringValue];
                //ScanSuccessCallback() 성공 콜백함수
                [self presentViewController:vc animated:NO completion:nil];
                */
                
            });
        }
    }
     
}

//닫기 버튼 추가
- (IBAction)closeButton:(id)sender {
    //SubViewContorller 닫기
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
