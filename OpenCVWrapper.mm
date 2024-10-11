//
//  OpenCVWrapper.mm
//  WorKit
//
//  Created by Ethan Donley on 9/22/24.
//

<<<<<<< HEAD
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat, alphaExists);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}
@end
=======
// OpenCVWrapper.mm
#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>
>>>>>>> 9811d77 (AI/OpenCV setup (With API sensitive info stored on Firebase))

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
<<<<<<< HEAD
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)grayscaleImg:(UIImage *)image {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    cv::Mat gray;
    
    NSLog(@"channels = %d", mat.channels());

    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(gray);
    }

    UIImage *grayImg = MatToUIImage(gray);
    return grayImg;
}

+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height :(int)interpolation {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    if (mat.channels() == 4) {
        [image convertToMat: &mat :true];
    }
    
    NSLog(@"source shape = (%d, %d)", mat.cols, mat.rows);
    
    cv::Mat resized;
    
//    cv::INTER_NEAREST = 0,
//    cv::INTER_LINEAR = 1,
//    cv::INTER_CUBIC = 2,
//    cv::INTER_AREA = 3,
//    cv::INTER_LANCZOS4 = 4,
//    cv::INTER_LINEAR_EXACT = 5,
//    cv::INTER_NEAREST_EXACT = 6,
//    cv::INTER_MAX = 7,
//    cv::WARP_FILL_OUTLIERS = 8,
//    cv::WARP_INVERSE_MAP = 16
    
    cv::Size size = {width, height};
    
    cv::resize(mat, resized, size, 0, 0, interpolation);
    
    NSLog(@"dst shape = (%d, %d)", resized.cols, resized.rows);
    
    UIImage *resizedImg = MatToUIImage(resized);
    
    return resizedImg;

=======
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
>>>>>>> 9811d77 (AI/OpenCV setup (With API sensitive info stored on Firebase))
}

@end
