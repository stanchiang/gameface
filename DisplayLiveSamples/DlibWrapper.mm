//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"
#import <UIKit/UIKit.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include "DlibWrapperDelegate.h"

@interface DlibWrapper ()

@property (assign) BOOL prepared;

+ (dlib::rectangle)convertScaleCGRect:(CGRect)rect toDlibRectacleWithImageSize:(CGSize)size;
+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects toVectorWithImageSize:(CGSize)size;

@end
@implementation DlibWrapper {
    dlib::shape_predictor sp;
}


-(instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

-(void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    
    if (!self.prepared) {
        [self prepare];
    }
    
    dlib::array2d<dlib::bgr_pixel> img;
    
    // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // set_size expects rows, cols format
    img.set_size(height, width);
    
    // copy samplebuffer image data into dlib image format
    img.reset();
    long position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();

        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        char r = baseBuffer[bufferLocation + 2];
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        dlib::bgr_pixel newpixel(b, g, r);
        pixel = newpixel;
        
        position++;
    }
    
    // unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    CGSize imageSize = CGSizeMake(width, height);
    
    // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [DlibWrapper convertCGRectValueArray:rects toVectorWithImageSize:imageSize];
    
    
    NSString *state = @"";
    // for every detected face
    for (unsigned long j = 0; j < convertedRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        // detect all landmarks
        dlib::full_object_detection shape = sp(img, oneFaceRect);
        
        dlib::point p = shape.part(63); //insideTopLip
        dlib::point q = shape.part(67); //insideBottomLip
        
//        NSLog(@"%li %li", p.x(), p.y());
        double dist = std::sqrt((p.x()-q.x())*(p.x()-q.x()) + (p.y()-q.y())*(p.y()-q.y()));
        
        NSArray *v = @[@62, @64, @66, @68];
        NSMutableArray *m = [NSMutableArray new];
        
//        for (NSNumber *n in v) {
//            dlib::point point = shape.part(NSInteger(n));
        dlib::point point62 = shape.part(NSInteger(62));
        [m addObject: [NSValue valueWithCGPoint:CGPointMake(point62.x(), point62.y())]];
        
        dlib::point point64 = shape.part(NSInteger(64));
        [m addObject: [NSValue valueWithCGPoint:CGPointMake(point64.x(), point64.y())]];
        
        dlib::point point66 = shape.part(NSInteger(66));
        [m addObject: [NSValue valueWithCGPoint:CGPointMake(point66.x(), point66.y())]];
        
        dlib::point point68 = shape.part(NSInteger(68));
        [m addObject: [NSValue valueWithCGPoint:CGPointMake(point68.x(), point68.y())]];
//        }
        
        [_delegate mouthVerticePositions:m];
        
        (dist < 40) ? state = @"closed" : state = @"open";
//        NSLog(@"%@ %f", state, dist);
        
        // and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
            draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
        }
    }
    
    // lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // copy dlib image data back into samplebuffer
    img.reset();
    position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        baseBuffer[bufferLocation] = pixel.blue;
        baseBuffer[bufferLocation + 1] = pixel.green;
        baseBuffer[bufferLocation + 2] = pixel.red;
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        position++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

+ (dlib::rectangle)convertScaleCGRect:(CGRect)rect toDlibRectangleWithImageSize:(CGSize)size {
    long right = (1.0 - rect.origin.y ) * size.width;
    long left = right - rect.size.height * size.width;
    long top = rect.origin.x * size.height;
    long bottom = top + rect.size.width * size.height;

//    long right = (rect.origin.x + rect.size.width) * size.width;
//    long left = rect.origin.x * size.width;
//    long top = rect.origin.y * size.height;
//    long bottom = (rect.origin.y + rect.size.height) * size.height;

    dlib::rectangle dlibRect(left, top, right, bottom);
    return dlibRect;
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects toVectorWithImageSize:(CGSize)size {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect singleRect = [rectValue CGRectValue];
        dlib::rectangle dlibRect = [DlibWrapper convertScaleCGRect:singleRect toDlibRectangleWithImageSize:size];
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}

@end
