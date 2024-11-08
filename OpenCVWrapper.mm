//
//  OpenCVWrapper.mm
//  WorKit
//
//  Created by Ethan Donley on 9/22/24.
//
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
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    if (!ciImage) {
        NSLog(@"Error: CIImage creation from CVPixelBuffer failed.");
        return nil;
    }

    // Create a CIContext to render the CIImage to a CGImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    
    if (!cgImage) {
        NSLog(@"Error: CGImage creation from CIImage failed.");
        return nil;
    }

    // Create UIImage from CGImage and release CGImage reference
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    if (!image.CGImage) {
        NSLog(@"Error: UIImage creation from CGImage has a NULL CGImage");
    }

    return image;
}


// Convert CVPixelBufferRef to cv::Mat
+ (cv::Mat)cvMatFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    cv::Mat mat;

    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    if (pixelFormat == kCVPixelFormatType_32BGRA) {
        void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        mat = cv::Mat(height, width, CV_8UC4, baseAddress, CVPixelBufferGetBytesPerRow(pixelBuffer));
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        // Handle YpCbCr 420 format (e.g., for front camera)
        cv::Mat yMat(height, width, CV_8UC1, CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0), CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0));
        cv::Mat uvMat(height / 2, width / 2, CV_8UC2, CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1), CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1));

        cv::cvtColorTwoPlane(yMat, uvMat, mat, cv::COLOR_YUV2RGB_NV12);
    } else if (pixelFormat == kCVPixelFormatType_OneComponent8) {
        void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        mat = cv::Mat(height, width, CV_8UC1, baseAddress, CVPixelBufferGetBytesPerRow(pixelBuffer));
    } else {
        NSLog(@"Unsupported pixel format: %u", (unsigned int)pixelFormat);
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    return mat;
}

// Convert cv::Mat to UIImage
+ (UIImage *)UIImageFromCVMat:(const cv::Mat&)mat {
    NSData *imageData = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

@end
