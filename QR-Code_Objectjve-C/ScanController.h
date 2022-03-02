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


@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;


- (IBAction)startButton:(id)sender;

- (BOOL)startReading;


@end

