//
//  ViewController.m
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/01/14.
//

#import "ScanController.h"
#import <WebKit/WebKit.h>

#import <AVFoundation/AVFoundation.h>

@interface ScanController () <AVCaptureMetadataOutputObjectsDelegate, UITableViewDelegate>

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewPlayer;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;

@end


@implementation ScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isReading = YES;
    _captureSession = nil;

}


- (IBAction)startButton:(id)sender {
    
    if(_isReading) {
        if([self startReading]){
            [_labelStatus setText:@"QR를 화면 안에 맞춰주세요."];
            [_startButton setTitle:@"스캔 중지" forState:UIControlStateHighlighted];
            
        }
    } else {
        [self stopReading];
        [_labelStatus setText:@"스캔 시작 버튼을 눌러주세요."];
        [_startButton setTitle:@"스캔 시작" forState:UIControlStateHighlighted];
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
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            [_labelStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObject stringValue] waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[_startButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
            
        }
    }
}


@end
