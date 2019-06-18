//
//  PhotoViewController.m
//  Vision-demo
//
//  Created by dabby on 2019/6/18.
//  Copyright © 2019 Jam. All rights reserved.
//

#import "PhotoViewController.h"
#import <Vision/Vision.h>

@interface PhotoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *detectionView;
@property (nonatomic, strong) NSMutableArray *requests;

@property (nonatomic, assign, readonly) CGSize detectionSize;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVision];
    // Do any additional setup after loading the view.
}

- (CGSize)detectionSize {
    return self.detectionView.frame.size;
}

- (IBAction)selectPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didSelectedPhoto:(UIImage *)image {
    self.imageView.image = image;
    CGImageRef imgRef = image.CGImage;
    VNImageRequestHandler *reqHandler = [[VNImageRequestHandler alloc] initWithCGImage:imgRef options:@{}];
    [reqHandler performRequests:self.requests error:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self didSelectedPhoto:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - vision

- (void)setupVision {
    
    VNDetectFaceRectanglesRequest *objectRecognitions = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"%@", request.results);
            [self handleWithResults:request.results];
        });
    }];
    self.requests = [NSMutableArray arrayWithObject:objectRecognitions];
}

- (void)handleWithResults:(NSArray *)results {
    self.detectionView.layer.sublayers = nil;
    for (VNFaceObservation *obs in results) {
        CGRect objectRect = VNImageRectForNormalizedRect(obs.boundingBox, self.detectionSize.width, self.detectionSize.height);
        //        VNClassificationObservation *firstLabel = obs.labels.firstObject;
        //        NSLog(@"id:%@, confidence:%f", firstLabel.identifier, firstLabel.confidence);
        NSLog(@"rect:%@", NSStringFromCGRect(objectRect));
        CALayer *rectLayer = [self layerWithDrawRectangle:objectRect];
        [self.detectionView.layer addSublayer:rectLayer];
    }
}

- (CALayer *)layerWithDrawRectangle:(CGRect)rect {
    CALayer *shapeLayer = [CALayer layer];
    shapeLayer.bounds = rect;
    CGFloat ceterY = CGRectGetMidY(rect);
    CGFloat midY = self.detectionSize.height / 2;
    ceterY = midY - (ceterY - midY);
    shapeLayer.position = CGPointMake(CGRectGetMidX(rect), ceterY);
    shapeLayer.name = @"found obj";
    shapeLayer.borderColor = [[UIColor greenColor] CGColor];
    shapeLayer.borderWidth = 2;
    return shapeLayer;
}

@end
