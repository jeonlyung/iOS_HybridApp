//
//  ViewController.m
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/01/14.
//

#import "ScanController.h"
#import <WebKit/WebKit.h>

#import <AVFoundation/AVFoundation.h>

@interface ScanController ()
@end


@implementation ScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isReading = NO;
    _captureSession = nil;
}


- (IBAction)startStopReading:(id)sender {
    if(!_isReading) {
        if([self startReading]){
            [_labelStatus setText:@"QR를 네모 안에 맞춰주세요."];
            [_startButton setTitle:@"촬영 중지"];
        }
    } else {
        [self stopReading];
        [_startButton setTitle:@"촬영 시작"];
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

- (IBAction)closeButton:(id)sender {
    [_startButton setTitle:@"테스트중"];
}

- (void)stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewPlayer removeFromSuperlayer];
}
    
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            [_labelStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObject stringValue] waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_startButton performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
            
        }
    }
}

@end
