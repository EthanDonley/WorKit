//
//  OpenCVWrapper.h
//  WorKit
//
//  Created by Ethan Donley on 9/22/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)getOpenCVVersion;
+ (UIImage *)grayscaleImg:(UIImage *)image;
+ (UIImage *)resizeImg:(UIImage *)image width:(int)width height:(int)height interpolation:(int)interpolation;

// Convert CVPixelBuffer to UIImage for Swift usage
+ (nullable UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
