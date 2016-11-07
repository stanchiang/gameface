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
        
//        for (int i = 0; i < [self.delegate getDelaunayEdges].count; i++) {
//            NSMutableArray *m = [self.delegate getDelaunayEdges][i];
//            for (int j = 0; j < m.count; j++) {
//                NSLog( @"%@", m[j]);
//            }
//        }
        
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
            
            CGPoint landmark = CGPointMake( [self pixelToPoints:shape.part(k).x()], [self pixelToPoints:shape.part(k).y()]);
            
            //inside lips outline
            if (k >= 60) { [m addObject: [NSValue valueWithCGPoint: landmark ]]; }
            
            //nose bridge
            if (k == 28) { [self.delegate noseBridgePosition: landmark ]; }
            
            //nose tip
            if (k == 31) { [self.delegate noseTipPosition: landmark ]; }
            
            if (rect.contains([self toCv:shape.part(k)])) {
                subdiv.insert([self toCv:shape.part(k)]);
            }
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

-(void) warpTriangle: (Mat &) img1 img2: (Mat &) img2 tri1: (vector<Point2f>) tri1 tri2: (vector<Point2f>) tri2 {
    // Find bounding rectangle for each triangle
    cv::Rect r1 = boundingRect(tri1);
    cv::Rect r2 = boundingRect(tri2);
    
    // Offset points by left top corner of the respective rectangles
    vector<Point2f> tri1Cropped, tri2Cropped;
    vector<cv::Point> tri2CroppedInt;
    for(int i = 0; i < 3; i++) {
        tri1Cropped.push_back( Point2f( tri1[i].x - r1.x, tri1[i].y -  r1.y) );
        tri2Cropped.push_back( Point2f( tri2[i].x - r2.x, tri2[i].y - r2.y) );
        
        // fillConvexPoly needs a vector of Point and not Point2f
        tri2CroppedInt.push_back( cv::Point((int)(tri2[i].x - r2.x), (int)(tri2[i].y - r2.y)) );
        
    }
    
    // Apply warpImage to small rectangular patches
    Mat img1Cropped;
    img1(r1).copyTo(img1Cropped);
    
    // Given a pair of triangles, find the affine transform.
    Mat warpMat = getAffineTransform( tri1Cropped, tri2Cropped );
    
    // Apply the Affine Transform just found to the src image
    Mat img2Cropped = Mat::zeros(r2.height, r2.width, img1Cropped.type());
    warpAffine( img1Cropped, img2Cropped, warpMat, img2Cropped.size(), INTER_LINEAR, BORDER_REFLECT_101);
    
    // Get mask by filling triangle
    Mat mask = Mat::zeros(r2.height, r2.width, CV_32FC3);
    fillConvexPoly(mask, tri2CroppedInt, Scalar(1.0, 1.0, 1.0), 16, 0);
    
    // Copy triangular region of the rectangular patch to the output image
    multiply(img2Cropped,mask, img2Cropped);
    multiply(img2(r2), Scalar(1.0,1.0,1.0) - mask, img2(r2));
    img2(r2) = img2(r2) + img2Cropped;
    
}

@end




//int main( int argc, char** argv) {
//    Point2f topLeft = Point2f(215,355);
//    Point2f topRight = Point2f(320,355);
//    Point2f bottomLeft = Point2f(215,400);
//    Point2f bottomRight = Point2f(320,400);
//    
//    Point2f center = Point2f(290,373);
//    Point2f newCenter = Point2f(260,373);
//    
//    // Input triangle
//    vector <Point2f> triIn; //left
//    triIn.push_back(topLeft);
//    triIn.push_back(bottomLeft);
//    triIn.push_back(center);
//    
//    // input tri 2
//    vector <Point2f> triIn2; //bottom
//    triIn2.push_back(bottomLeft);
//    triIn2.push_back(bottomRight);
//    triIn2.push_back(center);
//    
//    // input tri 3
//    vector <Point2f> triIn3; //top
//    triIn3.push_back(topRight);
//    triIn3.push_back(topLeft);
//    triIn3.push_back(center);
//    
//    // input tri 4
//    vector <Point2f> triIn4; //right
//    triIn4.push_back(bottomRight);
//    triIn4.push_back(topRight);
//    triIn4.push_back(center);
//    
//    
//    // Output triangle
//    vector <Point2f> triOut;
//    triOut.push_back(topLeft);
//    triOut.push_back(bottomLeft);
//    triOut.push_back(newCenter);
//    
//    //output tri 2
//    vector <Point2f> triOut2;
//    triOut2.push_back(bottomLeft);
//    triOut2.push_back(bottomRight);
//    triOut2.push_back(newCenter);
//    
//    //output tri 3
//    vector <Point2f> triOut3;
//    triOut3.push_back(topRight);
//    triOut3.push_back(topLeft);
//    triOut3.push_back(newCenter);
//    
//    //output tri 4
//    vector <Point2f> triOut4;
//    triOut4.push_back(bottomRight);
//    triOut4.push_back(topRight);
//    triOut4.push_back(newCenter);
//    
//    // Read input image and convert to float
//    Mat imgIn = imread("face.jpg");
//    imgIn.convertTo(imgIn, CV_32FC3, 1/255.0);
//    
//    // Output image is set to white
//    // Mat imgOut = Mat::ones(imgIn.size(), imgIn.type());
//    // imgOut = Scalar(1.0,1.0,1.0);
//    Mat imgOut = imread("face.jpg");
//    imgOut.convertTo(imgOut, CV_32FC3, 1/255.0);
//    
//    // Warp all pixels inside input triangle to output triangle
//    warpTriangle(imgIn, imgIn, triIn, triOut);
//    warpTriangle(imgIn, imgIn, triIn2, triOut2);
//    warpTriangle(imgIn, imgIn, triIn3, triOut3);
//    warpTriangle(imgIn, imgIn, triIn4, triOut4);
//    // Draw triangle on the input and output image.
//    
//    // Convert back to uint because OpenCV antialiasing
//    // does not work on image of type CV_32FC3
//    
//    imgIn.convertTo(imgIn, CV_8UC3, 255.0);
//    imgOut.convertTo(imgOut, CV_8UC3, 255.0);
//    
//    // Draw triangle using this color
//    Scalar black = Scalar(0, 0, 0);
//    Scalar red = Scalar(0, 0, 255);
//    Scalar blue = Scalar(255, 0, 0);
//    Scalar green = Scalar(0, 255, 0);
//    
//    // cv::polylines needs vector of type Point and not Point2f
//    vector <Point> triInInt, triOutInt;
//    vector <Point> triInInt2, triOutInt2;
//    vector <Point> triInInt3, triOutInt3;
//    vector <Point> triInInt4, triOutInt4;
//    
//    for(int i=0; i < 3; i++) {
//        triInInt.push_back(Point(triIn[i].x,triIn[i].y));
//        triInInt2.push_back(Point(triIn2[i].x,triIn2[i].y));
//        triInInt3.push_back(Point(triIn3[i].x,triIn3[i].y));
//        triInInt4.push_back(Point(triIn4[i].x,triIn4[i].y));
//        
//        triOutInt.push_back(Point(triOut[i].x,triOut[i].y));
//        triOutInt2.push_back(Point(triOut2[i].x,triOut2[i].y));
//        triOutInt3.push_back(Point(triOut3[i].x,triOut3[i].y));
//        triOutInt4.push_back(Point(triOut4[i].x,triOut4[i].y));
//        
//    }
//    
//    // Draw triangles in input and output images
//    bool showLines = true;
//    if (showLines) {
//        polylines(imgIn, triInInt, true, black, 1, 16);
//        polylines(imgIn, triInInt2, true, red, 1, 16);
//        polylines(imgIn, triInInt3, true, blue, 1, 16);
//        polylines(imgIn, triInInt4, true, green, 1, 16);
//        
//        polylines(imgOut, triOutInt, true, black, 1, 16);
//        polylines(imgOut, triOutInt2, true, red, 1, 16);
//        polylines(imgOut, triOutInt3, true, blue, 1, 16);
//        polylines(imgOut, triOutInt4, true, green, 1, 16);
//    }
//    
//    // Draw triangles in input and output images
//    
//    imshow("main", imgIn);
//    imshow("orig", imgOut);
//    waitKey(0);
//    
//    return 0;
//}
//
