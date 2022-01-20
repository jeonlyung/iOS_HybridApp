//
//  ViewController.h
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/01/14.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanController : UIViewController


@property (nonatomic) BOOL isReading;
    
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewPlayer;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;


@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
- (IBAction)startButton:(id)sender;

- (BOOL)startReading;
@end

