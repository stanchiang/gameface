//
//  CVFFaceDetect.m
//  CVFunhouse
//
//  Created by John Brewer on 7/22/12.
//  Copyright (c) 2012 Jera Design LLC. All rights reserved.
//

// Based on the OpenCV example: <opencv>/samples/c/facedetect.cpp

#import "CVFFaceDetect.h"

#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/imgproc/imgproc.hpp"

//Start - from dlib
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

#import <UIKit/UIKit.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>
//End - from dlib

//Start - from attentiontracker
#include <opencv2/highgui/highgui.hpp>
#include "head_pose_estimation.hpp"
//End - from attentiontracker

#include "CVFImageProcessorDelegate.h"

using namespace std;
using namespace cv;

CascadeClassifier cascade;
std::string modelFileNameCString;
double scale = 1;
dlib::shape_predictor sp;
@interface CVFFaceDetect() {
    bool _inited;
}

@end

@implementation CVFFaceDetect

-(void)processMat:(cv::Mat)mat
{
    if (!_inited) {
        NSString* haarDataPath =
        [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt.xml" ofType:nil];
        
        cascade.load([haarDataPath UTF8String]);
        
        NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
        modelFileNameCString = [modelFileName UTF8String];
        dlib::deserialize(modelFileNameCString) >> sp;
        
        _inited = true;
    }

    cvtColor(mat, mat, CV_BGR2RGB);

    int i = 0;
    vector<cv::Rect> faces;
    const static Scalar colors[] =  { CV_RGB(0,0,255),
        CV_RGB(0,128,255),
        CV_RGB(0,255,255),
        CV_RGB(0,255,0),
        CV_RGB(255,128,0),
        CV_RGB(255,255,0),
        CV_RGB(255,0,0),
        CV_RGB(255,0,255)} ;
    Mat gray, smallImg( cvRound (mat.rows/scale), cvRound(mat.cols/scale), CV_8UC1 );
    
    cvtColor( mat, gray, CV_RGB2GRAY );
    resize( gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR );
    equalizeHist( smallImg, smallImg );
    
    cascade.detectMultiScale( smallImg, faces,
                             1.2, 2, 0
                             //|CV_HAAR_FIND_BIGGEST_OBJECT
                             //|CV_HAAR_DO_ROUGH_SEARCH
                             |CV_HAAR_SCALE_IMAGE
                             ,
                             cv::Size(75, 75) );
    
    
    for( vector<cv::Rect>::const_iterator r = faces.begin(); r != faces.end(); r++, i++ ) {
        dlib::cv_image<dlib::bgr_pixel> dlibMat(mat);
        
//        for converting either direction use this http://stackoverflow.com/a/34873134/1079379
//        static cv::Rect dlibRectangleToOpenCV(dlib::rectangle r){return cv::Rect(cv::Point2i(r.left(), r.top()), cv::Point2i(r.right() + 1, r.bottom() + 1));}
//        static dlib::rectangle openCVRectToDlib(cv::Rect r){return dlib::rectangle((long)r.tl().x, (long)r.tl().y, (long)r.br().x - 1, (long)r.br().y - 1);}
        
        dlib::rectangle dlibRect((long)r->tl().x, (long)r->tl().y, (long)r->br().x - 1, (long)r->br().y - 1);
//        dlib::draw_rectangle(dlibMat, dlibRect, dlib::rgb_pixel(0, 255, 255));
        
        dlib::full_object_detection shape = sp(dlibMat, dlibRect);
        NSMutableArray *m = [NSMutableArray new];
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            draw_solid_circle(dlibMat, shape.part(k), 3, dlib::rgb_pixel(0, 255, 255));
            if (k >= 60) {
                [m addObject: [NSValue valueWithCGPoint:CGPointMake( [self pixelToPoints:shape.part(k).x()], [self pixelToPoints:shape.part(k).y()]) ]];
            }
        }
        [self.delegate mouthVerticePositions:m];
    }
    
    [self matReady:mat];
}

- (CGFloat)pixelToPoints:(CGFloat)px {
    CGFloat pointsPerInch = 72.0; // see: http://en.wikipedia.org/wiki/Point%5Fsize#Current%5FDTP%5Fpoint%5Fsystem
    CGFloat scale = 1; // We dont't use [[UIScreen mainScreen] scale] as we don't want the native pixel, we want pixels for UIFont - it does the retina scaling for us
    float pixelPerInch; // aka dpi
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        pixelPerInch = 132 * scale;
//    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        pixelPerInch = 163 * scale;
//    } else {
//        pixelPerInch = 160 * scale;
//    }

    pointsPerInch += 22.5;
    CGFloat result = px * pointsPerInch / pixelPerInch;
    return result;
}

@end
