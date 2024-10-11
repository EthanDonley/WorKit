//
//  OpenCVWrapper.mm
//  WorKit
//
//  Created by Ethan Donley on 9/22/24.
//

// OpenCVWrapper.mm
#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
    std::string version = cv::getVersionString();
    return [NSString stringWithUTF8String:version.c_str()];
}

// Convert CVPixelBufferRef to UIImage for Swift
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    cv::Mat mat = [OpenCVWrapper cvMatFromPixelBuffer:pixelBuffer];
    return [OpenCVWrapper UIImageFromCVMat:mat];
}

// Convert CVPixelBufferRef to cv::Mat
+ (cv::Mat)cvMatFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);

    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    cv::Mat mat;

    if (pixelFormat == kCVPixelFormatType_32BGRA) {
        mat = cv::Mat(height, width, CV_8UC4, baseAddress, CVPixelBufferGetBytesPerRow(pixelBuffer));
    } else if (pixelFormat == kCVPixelFormatType_OneComponent8) {
        mat = cv::Mat(height, width, CV_8UC1, baseAddress, CVPixelBufferGetBytesPerRow(pixelBuffer));
    } else {
        NSLog(@"Unsupported pixel format: %u", (unsigned int)pixelFormat);
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    return mat;
}

// Convert cv::Mat to UIImage
+ (UIImage *)UIImageFromCVMat:(const cv::Mat&)mat {
    return MatToUIImage(mat);
}

@end
