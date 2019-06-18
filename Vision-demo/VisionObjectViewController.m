//
//  VisionObjectViewController.m
//  Vision-demo
//
//  Created by dabby on 2019/6/17.
//  Copyright © 2019 Jam. All rights reserved.
//

#import "VisionObjectViewController.h"
#import <Vision/Vision.h>

@interface VisionObjectViewController ()

@property (nonatomic, strong) CALayer *detectionLayer;
@property (nonatomic, strong) NSMutableArray *requests;

@end

@implementation VisionObjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)config {
    [super config];
    [self setupLayer];
    [self setupVision];
    [self startCapture];
}

- (void)setupLayer {
    self.detectionLayer = [CALayer layer];
    self.detectionLayer.name = @"detectionLayer";
    self.detectionLayer.bounds = CGRectMake(0, 0, self.detectionSize.width, self.detectionSize.height);
    self.detectionLayer.position = self.view.center;
    [self.view.layer addSublayer:self.detectionLayer];
}

- (void)setupVision {
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"YOLOv3Tiny" withExtension:@"mlmodelc"];
//    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:nil];
//    VNCoreMLModel *visionModel = [VNCoreMLModel modelForMLModel:model error:nil];
//    VNCoreMLRequest *objectRecognitions = [[VNCoreMLRequest alloc] initWithModel:visionModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //            NSLog(@"%@", request.results);
//            [self handleWithResults:request.results];
//        });
//    }];
    
    VNDetectFaceLandmarksRequest *objectRecognitions = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"%@", request.results);
            [self handleWithResults:request.results];
        });
    }];
    self.requests = [NSMutableArray arrayWithObject:objectRecognitions];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    VNImageRequestHandler *imgReqHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationRight options:@{}];
    [imgReqHandler performRequests:self.requests error:nil];
}

- (void)handleWithResults:(NSArray *)results {
    [CATransaction begin];
    [CATransaction setValue:(__bridge id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.detectionLayer.sublayers = nil;
    for (VNFaceObservation *obs in results) {
        [self.detectionLayer addSublayer:[self layerDrawWithFaceObservation:obs]];
    }
    [CATransaction commit];
}

- (CALayer *)layerDrawWithFaceObservation:(VNFaceObservation *)faceObservation {
    CALayer *detectionLayer = [CALayer layer];
    detectionLayer.frame = CGRectMake(0, 0, self.detectionSize.width, self.detectionSize.height);
    
    CGRect rect = VNImageRectForNormalizedRect(faceObservation.boundingBox, self.detectionSize.width, self.detectionSize.height);
    rect.origin.y = self.detectionSize.height - rect.origin.y - rect.size.height;
    CALayer *shapeLayer = [CALayer layer];
    shapeLayer.bounds = rect;
    shapeLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    shapeLayer.name = @"found obj";
    shapeLayer.borderColor = [[UIColor greenColor] CGColor];
    shapeLayer.borderWidth = 1;
    [detectionLayer addSublayer:shapeLayer];
    
    VNFaceLandmarks2D *landmarks = faceObservation.landmarks;
    // draw text
    float confidence = landmarks.confidence;
    CATextLayer *textLayer = [CATextLayer layer];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.4f", confidence] attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:13] forKey:NSFontAttributeName]];
    textLayer.string = string;
    textLayer.backgroundColor = [[UIColor greenColor] CGColor];
    textLayer.foregroundColor = [[UIColor blackColor] CGColor];
    textLayer.frame = CGRectMake(rect.origin.x, rect.origin.y - 13, rect.size.width, 13);
    textLayer.contentsScale = UIScreen.mainScreen.scale;
    [detectionLayer addSublayer:textLayer];
    
    // draw points
    VNFaceLandmarkRegion2D *allPoints = landmarks.allPoints;
    NSUInteger pointsCount = allPoints.pointCount;
    const CGPoint *points = [allPoints pointsInImageOfSize:self.detectionSize];
    for (NSUInteger i = 0; i < pointsCount; i++) {
        CGPoint p = points[i];
        p.y = self.detectionSize.height - p.y;
        CALayer *pointLayer = [CALayer layer];
        pointLayer.bounds = CGRectMake(0, 0, 2, 2);
        pointLayer.position = p;
        pointLayer.backgroundColor = [[UIColor redColor] CGColor];
        [detectionLayer addSublayer:pointLayer];
    }
    
    return detectionLayer;
}

@end
