//
//  CameraViewController.h
//  Vision-demo
//
//  Created by dabby on 2019/6/17.
//  Copyright © 2019 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign, readonly) CGSize detectionSize;

- (void)startCapture;
- (void)config;

@end

NS_ASSUME_NONNULL_END
