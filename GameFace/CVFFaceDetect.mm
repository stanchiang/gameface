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
        
        for (int i = 0; i < [self.delegate getDelaunayEdges].count; i++) {
            NSMutableArray *m = [self.delegate getDelaunayEdges][i];
            for (int j = 0; j < m.count; j++) {
                NSLog( @"%@", m[j]);
            }
        }
        
        _inited = true;
    }

    cvtColor(mat, mat, CV_BGR2RGB);

    int i = 0;
    vector<cv::Rect> faces;
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
        if ([self.delegate showFaceDetect]) {
            dlib::draw_rectangle(dlibMat, dlibRect, dlib::rgb_pixel(0, 255, 255));
        }
        
        dlib::full_object_detection shape = sp(dlibMat, dlibRect);
        NSMutableArray *m = [NSMutableArray new];
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            if ([self.delegate showFaceDetect]) {
                draw_solid_circle(dlibMat, shape.part(k), 3, dlib::rgb_pixel(0, 255, 255));
            }
            
            if (k >= 60) {
                [m addObject: [NSValue valueWithCGPoint:CGPointMake( [self pixelToPoints:shape.part(k).x()], [self pixelToPoints:shape.part(k).y()]) ]];
            }
        }
        
//        [self drawDelaunayMask:dlibMat shape:shape];
        [self.delegate mouthVerticePositions:m];
        
    }
    
//    cv::Mat edges;
//    cvtColor(mat, edges, CV_BGR2GRAY);
//    GaussianBlur(edges, edges, cv::Size(7, 7), 1.5, 1.5);
//    Canny(edges, edges, 0, 30, 3);
//    Canny(edges, edges, 10, 100, 3);

//    [self matReady:edges];
    [self matReady:mat];
}

- (CGFloat)pixelToPoints:(CGFloat)px {
    CGFloat pointsPerInch = 72.0; // see: http://en.wikipedia.org/wiki/Point%5Fsize#Current%5FDTP%5Fpoint%5Fsystem
    
    float pixelPerInch = 163; // aka dpi
    
    pointsPerInch += [self.delegate adjustPPI];
    CGFloat result = px * pointsPerInch / pixelPerInch;
    return result;
}

- (void) drawDelaunayMask: (dlib::cv_image<dlib::bgr_pixel>) dlibMat shape:(dlib::full_object_detection) shape {
    dlib::draw_line(dlibMat,shape.part(0),shape.part(1),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(0),shape.part(17),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(0),shape.part(36),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(1),shape.part(2),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(1),shape.part(36),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(1),shape.part(41),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(2),shape.part(3),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(2),shape.part(31),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(2),shape.part(41),dlib::rgb_pixel(0,255,0));
    
    dlib::draw_line(dlibMat,shape.part(17),shape.part(18),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(17),shape.part(36),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(18),shape.part(19),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(18),shape.part(36),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(18),shape.part(37),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(19),shape.part(20),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(19),shape.part(37),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(20),shape.part(21),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(20),shape.part(37),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(20),shape.part(38),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(20),shape.part(23),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(21),shape.part(23),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(21),shape.part(22),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(21),shape.part(27),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(21),shape.part(38),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(21),shape.part(39),dlib::rgb_pixel(0,255,0));
    
    dlib::draw_line(dlibMat,shape.part(36),shape.part(37),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(36),shape.part(41),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(37),shape.part(38),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(37),shape.part(40),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(37),shape.part(41),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(38),shape.part(39),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(38),shape.part(40),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(39),shape.part(27),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(39),shape.part(28),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(39),shape.part(29),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(39),shape.part(40),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(40),shape.part(29),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(40),shape.part(31),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(40),shape.part(41),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(41),shape.part(31),dlib::rgb_pixel(0,255,0));
    
    dlib::draw_line(dlibMat,shape.part(22),shape.part(23),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(22),shape.part(27),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(22),shape.part(47),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(22),shape.part(42),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(22),shape.part(43),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(23),shape.part(24),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(23),shape.part(43),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(24),shape.part(25),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(24),shape.part(43),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(24),shape.part(44),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(25),shape.part(26),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(25),shape.part(44),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(25),shape.part(45),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(26),shape.part(16),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(26),shape.part(45),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(16),shape.part(45),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(16),shape.part(15),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(15),shape.part(14),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(15),shape.part(45),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(27),shape.part(28),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(27),shape.part(42),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(42),shape.part(28),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(42),shape.part(29),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(42),shape.part(43),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(42),shape.part(47),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(42),shape.part(35),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(43),shape.part(44),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(43),shape.part(47),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(44),shape.part(45),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(44),shape.part(46),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(44),shape.part(47),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(45),shape.part(46),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(46),shape.part(47),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(46),shape.part(35),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(47),shape.part(35),dlib::rgb_pixel(0,255,0));

    dlib::draw_line(dlibMat,shape.part(28),shape.part(29),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(29),shape.part(30),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(29),shape.part(31),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(29),shape.part(35),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(30),shape.part(31),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(30),shape.part(32),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(30),shape.part(33),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(30),shape.part(34),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(30),shape.part(35),dlib::rgb_pixel(0,255,0));
    
    dlib::draw_line(dlibMat,shape.part(31),shape.part(32),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(32),shape.part(33),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(33),shape.part(34),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(34),shape.part(35),dlib::rgb_pixel(0,255,0));

    dlib::draw_line(dlibMat,shape.part(3),shape.part(4),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(4),shape.part(5),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(5),shape.part(6),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(6),shape.part(7),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(7),shape.part(8),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(8),shape.part(9),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(9),shape.part(10),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(10),shape.part(11),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(11),shape.part(12),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(12),shape.part(13),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(13),shape.part(14),dlib::rgb_pixel(0,255,0));

    dlib::draw_line(dlibMat,shape.part(48),shape.part(49),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(49),shape.part(50),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(50),shape.part(51),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(51),shape.part(52),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(52),shape.part(53),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(53),shape.part(54),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(55),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(55),shape.part(56),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(56),shape.part(57),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(57),shape.part(58),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(58),shape.part(59),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(59),shape.part(48),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(60),shape.part(61),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(61),shape.part(62),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(62),shape.part(63),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(63),shape.part(64),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(64),shape.part(65),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(65),shape.part(66),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(66),shape.part(67),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(67),shape.part(60),dlib::rgb_pixel(0,255,0));
    
    dlib::draw_line(dlibMat,shape.part(48),shape.part(31),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(48),shape.part(3),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(48),shape.part(4),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(48),shape.part(5),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(59),shape.part(5),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(59),shape.part(6),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(58),shape.part(6),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(58),shape.part(7),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(57),shape.part(7),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(57),shape.part(8),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(56),shape.part(8),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(56),shape.part(9),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(55),shape.part(9),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(55),shape.part(10),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(10),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(11),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(11),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(12),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(13),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(14),dlib::rgb_pixel(0,255,0));
    dlib::draw_line(dlibMat,shape.part(54),shape.part(46),dlib::rgb_pixel(0,255,0));
    
}

@end
