//
//  OpenCVWrapper.mm
//  WorKit
//
//  Created by Ethan Donley on 9/22/24.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>  // Required for UIImage handling

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
    // Get OpenCV version
    std::string version = cv::getVersionString();
    
    // Convert std::string to NSString and return
    return [NSString stringWithUTF8String:version.c_str()];
}


+ (UIImage * _Nullable)startCameraAndTrackPose {
    // Open the camera
    cv::VideoCapture capture(0);  // 0 is the default camera (front-facing)
    if (!capture.isOpened()) {
        NSLog(@"Error: Could not open camera.");
        return nil;  // Return nil if the camera fails to open
    }
    
    NSLog(@"Camera opened successfully.");

    cv::Mat frame;
    bool frameCaptured = capture.read(frame);  // Capture a single frame
    
    if (!frameCaptured) {
        NSLog(@"Error: Could not capture a frame.");
        return nil;
    }

    if (frame.empty()) {
        NSLog(@"Error: Captured frame is empty.");
        return nil;
    }
    
    NSLog(@"Captured frame successfully.");

    // Convert the frame to UIImage and return it
    UIImage *image = [OpenCVWrapper matToUIImage:frame];
    capture.release();  // Release the camera after capturing the frame
    return image;
}

+ (UIImage *)matToUIImage:(const cv::Mat &)mat {
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
    CGColorSpaceRef colorSpace;

    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(mat.cols,                               // Width
                                        mat.rows,                               // Height
                                        8,                                      // Bits per component
                                        8 * mat.elemSize(),                     // Bits per pixel
                                        mat.step[0],                            // Bytes per row
                                        colorSpace,                             // Color space
                                        kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault, // Bitmap info flags
                                        provider,                               // CGDataProviderRef
                                        NULL,                                   // Decode
                                        false,                                  // Should interpolate
                                        kCGRenderingIntentDefault);             // Intent

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return image;
}

@end
