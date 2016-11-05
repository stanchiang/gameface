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
//        if ([self.delegate showFaceDetect]) {
//            dlib::draw_rectangle(dlibMat, dlibRect, dlib::rgb_pixel(0, 255, 255));
//        }
        
        dlib::full_object_detection shape = sp(dlibMat, dlibRect);
        NSMutableArray *m = [NSMutableArray new];
        
        /////
        // Draws the contours of the face and face features onto the image
        
        // Define colors for drawing.
        Scalar delaunay_color(255,255,255), points_color(0, 0, 255);
        
        // Rectangle to be used with Subdiv2D
        cv::Size size = mat.size();
        cv::Rect rect(0, 0, size.width, size.height);
        
        // Create an instance of Subdiv2D
        Subdiv2D subdiv(rect);
        /////
        
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            if ([self.delegate showFaceDetect]) {
                draw_solid_circle(dlibMat, shape.part(k), 3, dlib::rgb_pixel(0, 255, 0));
            }
            
            if (k >= 60) {
                [m addObject: [NSValue valueWithCGPoint:CGPointMake( [self pixelToPoints:shape.part(k).x()], [self pixelToPoints:shape.part(k).y()]) ]];
            }
            
            subdiv.insert([self toCv:shape.part(k)]);
        }
//        if ([self.delegate showFaceDetect]) {
            [self draw_delaunay:mat subdiv:subdiv delaunay:delaunay_color];
//        }
        [self.delegate mouthVerticePositions:m];
        
    }

    [self matReady:mat];
    
//    cv::Mat edges;
//    cvtColor(mat, edges, CV_BGR2GRAY);
//    GaussianBlur(edges, edges, cv::Size(7, 7), 1.5, 1.5);
//    Canny(edges, edges, 0, 30, 3);
//    Canny(edges, edges, 10, 100, 3);
//    [self matReady:edges];

}

- (CGFloat)pixelToPoints:(CGFloat)px {
    CGFloat pointsPerInch = 72.0; // see: http://en.wikipedia.org/wiki/Point%5Fsize#Current%5FDTP%5Fpoint%5Fsystem
    
    float pixelPerInch = 163; // aka dpi
    
    pointsPerInch += [self.delegate adjustPPI];
    CGFloat result = px * pointsPerInch / pixelPerInch;
    return result;
}

-(Point2f) toCv: (dlib::point&) p {
    return cv::Point2f(p.x(), p.y());
}

// Draw delaunay triangles
-(void) draw_delaunay: (Mat&) img subdiv: (Subdiv2D&) subdiv delaunay: (Scalar) delaunay_color {
    
    std::vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    std::vector<cv::Point> pt(3);
    cv::Size size = img.size();
    cv::Rect rect(0,0, size.width, size.height);
    
    for( size_t i = 0; i < triangleList.size(); i++ )
    {
        Vec6f t = triangleList[i];
        pt[0] = cv::Point(cvRound(t[0]), cvRound(t[1]));
        pt[1] = cv::Point(cvRound(t[2]), cvRound(t[3]));
        pt[2] = cv::Point(cvRound(t[4]), cvRound(t[5]));
        
        // Draw rectangles completely inside the image.
        if ( rect.contains(pt[0]) && rect.contains(pt[1]) && rect.contains(pt[2]))
        {
            cv::line(img, pt[0], pt[1], delaunay_color, 1, CV_AA, 0);
            cv::line(img, pt[1], pt[2], delaunay_color, 1, CV_AA, 0);
            cv::line(img, pt[2], pt[0], delaunay_color, 1, CV_AA, 0);
        }
    }
}

@end
