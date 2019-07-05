//
//  YD_UpendViewController.m
//  YD_VideoEidtManager
//
//  Created by mac on 2019/7/1.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YD_UpendViewController.h"
#import "YD_PlayerView.h"
#import "YD_DefaultPlayControlView.h"

@interface YD_UpendViewController ()

@property (nonatomic, weak) UIView *containView;
@property (nonatomic, weak) UIButton *upendBtn;
@property (nonatomic, weak) UIButton *restoreBtn;
@property (nonatomic, weak) UILabel *titleLbl;

@property (nonatomic, weak) UIImageView *imgView;

@property (nonatomic, strong) AVAsset *upendAsset;
/// 是否是倒放
@property (nonatomic, assign) BOOL isUpend;

@end

@implementation YD_UpendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)yd_layoutSubViews {
    
    [super yd_layoutSubViews];

    {
        UIView *view = [UIView new];
        self.containView = view;
        [self.view addSubview:view];
        
        UIButton *rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.upendBtn = rotateBtn;
        rotateBtn.backgroundColor = self.model.themeColor;
        rotateBtn.layer.masksToBounds = YES;
        rotateBtn.layer.cornerRadius = 5;
        [rotateBtn setTitle:@"立即倒放" forState:UIControlStateNormal];
        [rotateBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        rotateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [rotateBtn addTarget:self action:@selector(yd_upendAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:rotateBtn];
        
        UIButton *restoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.restoreBtn = restoreBtn;
        restoreBtn.layer.borderWidth = 1.0;
        restoreBtn.layer.borderColor = self.model.themeColor.CGColor;
        restoreBtn.layer.masksToBounds = YES;
        restoreBtn.layer.cornerRadius = 5;
        [restoreBtn setTitle:@"复 原" forState:UIControlStateNormal];
        [restoreBtn setTitleColor:self.model.themeColor forState:UIControlStateNormal];
        restoreBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [restoreBtn addTarget:self action:@selector(yd_restoreAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:restoreBtn];
        
        UILabel *label = [UILabel new];
        self.titleLbl = label;
        label.text = @"(视频倒放后将会没有声）";
        label.textColor = [UIColor colorWithHexString:@"#999999"];
        label.font = [UIFont systemFontOfSize:10];
        [view addSubview:label];
    }
    
    UIImageView *imgView = [UIImageView new];
    self.imgView = imgView;
    imgView.frame = CGRectMake(20, 100, YD_ScreenWidth - 40, YD_ScreenHeight - 150);
    [self.view addSubview:imgView];
}

- (void)yd_layoutConstraints {

    [super yd_layoutConstraints];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.inset(0);
        make.top.equalTo(self.player.mas_bottom);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];
    
    [self.upendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containView);
        make.centerY.equalTo(self.containView).offset(-40);
        make.width.mas_equalTo(132);
        make.height.mas_equalTo(36);
    }];
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containView);
        make.top.equalTo(self.upendBtn.mas_bottom).inset(6);
    }];
    
    [self.restoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containView);
        make.size.equalTo(self.upendBtn);
        make.top.equalTo(self.upendBtn.mas_bottom).inset(50);
    }];
}

#pragma mark - 重写的方法
- (NSString *)yd_title {
    return @"倒放";
}

- (UIImage *)yd_barIconImage {
    return self.model.barIconImage ?: [UIImage yd_imageWithName:@"yd_upend@3x"];
}

- (void)yd_completeItemAction {
    
    [self.player yd_pause];
    
    [YD_ProgressHUD yd_showHUD:@"正在处理视频，请不要锁屏或者切到后台"];
    
    @weakify(self);
    if (self.isUpend) {
        @weakify(self);
        [YD_AssetManager yd_upendAsset:self.model.asset finish:^(BOOL isSuccess, NSString * _Nonnull exportPath) {
            @strongify(self);
            [YD_ProgressHUD yd_hideHUD];
            if (isSuccess) {
                [self yd_pushPreview:exportPath];
            }else {
                [YD_ProgressHUD yd_showMessage:@"视频处理取消" toView:self.view];
            }
        }];
        
    }else {
        [YD_AssetManager yd_exporter:self.model.asset fileName:@"upend.mp4" finish:^(BOOL isSuccess, NSString * _Nonnull exportPath) {
            @strongify(self);
            [YD_ProgressHUD yd_hideHUD];
            if (isSuccess) {
                [self yd_pushPreview:exportPath];
            }else {
                [YD_ProgressHUD yd_showMessage:@"视频处理取消" toView:self.view];
            }
        }];
    }
}

#pragma mark - UI事件
- (void)yd_restoreAction {
    self.isUpend = NO;
    [self.player yd_pause];
    [self yd_playWithAsset:self.model.asset];
}

- (void)yd_playWithAsset:(AVAsset *)asset {
    self.playModel.asset = asset;
    self.player.yd_model = self.playModel;
    [self.player yd_play];
}

- (void)yd_upendAction {
    
    self.isUpend = YES;
    [self.player yd_pause];
    
    if (self.upendAsset) {
        [self yd_playWithAsset:self.upendAsset];
        return;
    }

    [YD_ProgressHUD yd_showHUD:@"正在处理视频，请不要锁屏或者切到后台"];

    @weakify(self);
    [YD_AssetManager yd_upendAsset:self.model.asset finish:^(BOOL isSuccess, NSString * _Nonnull exportPath) {
        @strongify(self);
        [YD_ProgressHUD yd_hideHUD];
        if (isSuccess) {
            self.upendAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:exportPath]];
            [self yd_playWithAsset:self.upendAsset];
        }else {
            [YD_ProgressHUD yd_showMessage:@"视频处理取消" toView:self.view];
        }
    }];
    
//    dispatch_async(dispatch_queue_create("UpendMovieQueue", DISPATCH_QUEUE_SERIAL), ^{
//
//        AVAsset *asset = self.model.asset;
//
//        NSError *error;
//        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
//        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
//        NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
//        AVAssetReaderTrackOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:readerOutputSettings];
//        readerOutput.alwaysCopiesSampleData = NO;
//        // 在开始读取之前给reader指定一个output
//        [reader addOutput:readerOutput];
//        [reader startReading];
//
//        NSString *outputPath = [YD_PathCache stringByAppendingString:@"upendMovie.mp4"];
//        // 删除当前该路径下的文件
//        unlink([outputPath UTF8String]);
//        NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
//
//        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
//        NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:@(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey, nil];
//
//        CGFloat width = YD_ScreenWidth;
//        CGFloat height = videoTrack.naturalSize.height / videoTrack.naturalSize.width * width;
//        NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                              AVVideoCodecH264, AVVideoCodecKey,
//                                              [NSNumber numberWithInt:width], AVVideoWidthKey,
//                                              [NSNumber numberWithInt:height], AVVideoHeightKey,
//                                              videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
//        AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
//        [writerInput setExpectsMediaDataInRealTime:NO];
//        writerInput.transform = videoTrack.preferredTransform;
//
//        AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
//        [writer addInput:writerInput];
//        [writer startWriting];
//
//        Float64 seconds = [asset yd_getSeconds];
//        float fps = [asset yd_getFPS];
//        Float64 totalFrames = seconds * fps; //获得视频总帧数
//
//        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//        gen.requestedTimeToleranceAfter = kCMTimeZero;
//        gen.requestedTimeToleranceBefore = kCMTimeZero;
//        gen.appliesPreferredTrackTransform = YES;
//
//        [writer startSessionAtSourceTime:kCMTimeZero];
//
//        for (int i = 1; i < totalFrames; i++) {
//            @autoreleasepool {
//                CMTime time = CMTimeMake(i * 20, 600);
//                UIImage *img = [self yd_getVideoImage:time gen:gen];
//                CVPixelBufferRef imageBufferRef = [self pixelBufferFromCGImage:img.CGImage size:img.size];
//
//                while (!writerInput.readyForMoreMediaData) {
//                    [NSThread sleepForTimeInterval:0.1];
//                }
//                [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:time];
//            }
//        }
//
//        @weakify(self);
//        [writer finishWritingWithCompletionHandler:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self);
//                [YD_ProgressHUD yd_hideHUD];
//                 self.upendAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:outputPath]];
//                [self yd_playWithAsset:self.upendAsset];
//            });
//        }];
//    });
}

- (UIImage *)yd_getVideoImage:(CMTime)time gen:(AVAssetImageGenerator *)gen {
    CMTime actualTime;
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:nil];
    UIImage *img = imageRef ? [[UIImage alloc] initWithCGImage:imageRef] : nil;
    CGImageRelease(imageRef);
    return img;
}

+ (void)yd_upendAsset:(AVAsset *)asset finish:(YD_ExportFinishBlock)finishBlock {
    dispatch_async(dispatch_queue_create("UpendMovieQueue", DISPATCH_QUEUE_SERIAL), ^{
        NSError *error;
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
        AVAssetReaderTrackOutput *readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:readerOutputSettings];
        readerOutput.alwaysCopiesSampleData = NO;
        // 在开始读取之前给reader指定一个output
        [reader addOutput:readerOutput];
        [reader startReading];
        
        NSString *outputPath = [YD_PathCache stringByAppendingString:@"upendMovie.mp4"];
        // 删除当前该路径下的文件
        unlink([outputPath UTF8String]);
        NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
        
        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
        NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:@(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey, nil];
        NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                              [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                              videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
        AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
        [writerInput setExpectsMediaDataInRealTime:NO];
        writerInput.transform = videoTrack.preferredTransform;
        
        AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
        [writer addInput:writerInput];
        [writer startWriting];
        
        NSMutableArray *samples = [[NSMutableArray alloc] init];
        CMSampleBufferRef sample;
        while ((sample = [readerOutput copyNextSampleBuffer])) {
            [samples addObject:(__bridge id)sample];
            CFRelease(sample);
        }
        
        [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[0])];
        
        for (NSInteger i = 0; i < samples.count; i ++) {
            CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[i]);
            CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)samples[samples.count - i - 1]);
            while (!writerInput.readyForMoreMediaData) {
                [NSThread sleepForTimeInterval:0.1];
            }
            [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
        }
        
        [writer finishWritingWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finishBlock) {
                    finishBlock(!error, outputPath);
                    if (error) {  NSLog(@"----- %@", error); }
                }
            });
        }];
    });
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                             
                             [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata !=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    
    //    当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项
    
    CGContextRef context = CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    
    NSParameterAssert(context);
    
    //使用CGContextDrawImage绘制图片  这里设置不正确的话 会导致视频颠倒
    
    //    当通过CGContextDrawImage绘制图片到一个context中时，如果传入的是UIImage的CGImageRef，因为UIKit和CG坐标系y轴相反，所以图片绘制将会上下颠倒
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    // 释放色彩空间
    
    CGColorSpaceRelease(rgbColorSpace);
    
    // 释放context
    
    CGContextRelease(context);
    
    // 解锁pixel buffer
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}

@end

