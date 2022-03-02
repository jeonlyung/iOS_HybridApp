//
//  ScanViewController.h
//  horsepia_iOS_new
//
//  Created by 한국마사회 on 2022/02/16.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIButton *startButton;


@property (nonatomic, copy) void (^callback)(NSString *result);

- (IBAction)startButton:(id)sender;
@end

NS_ASSUME_NONNULL_END
