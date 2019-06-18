//
//  CameraViewController.m
//  Vision-demo
//
//  Created by dabby on 2019/6/17.
//  Copyright © 2019 Jam. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@property (nonatomic, strong) AVCaptureSession          *session;
@property (nonatomic, strong) AVCaptureDeviceInput      *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput   *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDevice           *device;

@end

@implementation CameraViewController {
    CGSize _detectionSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Camera";
    [self config];
    // Do any additional setup after loading the view.
}

- (CGSize)detectionSize {
    return _detectionSize;
}

- (void)startCapture {
    [self.session startRunning];
}

- (void)config {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.device = captureDevice;
    // 摄像头判断
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    
    //拍摄会话
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
        self.output.alwaysDiscardsLateVideoFrames = YES;
        self.output.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        [self.output setSampleBufferDelegate:self queue:dispatch_queue_create(0, 0)];
    }
    
//    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(self.device.activeFormat.formatDescription);
//    _detectionSize.width = dimensions.width;
//    _detectionSize.height = dimensions.height;
    _detectionSize = self.view.bounds.size;
    
    // 设置预览图层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    // 开始采集数据
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"%@", output);
}

@end
