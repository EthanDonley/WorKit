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
    // Attempt CIImage conversion
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    if (!ciImage) {
        NSLog(@"Error: CIImage creation from CVPixelBuffer failed.");
        return nil;
    }

    // Render the CIImage to a CGImage
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

// Fallback conversion: Using CGContext for UIImage creation
+ (UIImage *)fallbackImageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];

    // Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(cgImage);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

    return image;
}

@end
