//#include <cmath>
//#include <ctime>
//
//#include <opencv2/calib3d/calib3d.hpp>
//#include <opencv2/imgproc/imgproc.hpp>
//#include <iostream>
//
//#include "head_pose_estimation.hpp"
//
//using namespace dlib;
//using namespace std;
//using namespace cv;
//
//inline Point2f toCv(const dlib::point& p) {
//    return Point2f(p.x(), p.y());
//}
//
//HeadPoseEstimation::HeadPoseEstimation(const string& face_detection_model, float focalLength) :
//        focalLength(focalLength),
//        opticalCenterX(-1),
//        opticalCenterY(-1) {
//
//        // Load face detection and pose estimation models.
//        detector = get_frontal_face_detector();
//        deserialize(face_detection_model) >> pose_model;
//
//}
//
//void HeadPoseEstimation::update(cv::InputArray _image, double subsample_detection_frame) {
//
//    Mat image = _image.getMat();
//
//	current_image = cv_image<bgr_pixel>(image);
//	shapes.clear();
//	
//	faces = detector(current_image,0);
//	
//	for (auto face : faces){
//		// Find the pose of each face.
//		shapes.push_back(pose_model(current_image, face));
//	}
//
//    // Draws the contours of the face and face features onto the image
//
//    // Define colors for drawing.
//    Scalar delaunay_color(255,255,255), points_color(0, 0, 255);
//
//    // Rectangle to be used with Subdiv2D
//    Size size = image.size();
//    Rect rect(0, 0, size.width, size.height);
//
//    // Create an instance of Subdiv2D
//    Subdiv2D subdiv(rect);
//    
//    for (unsigned long i = 0; i < shapes.size(); ++i) {
//        
//        const full_object_detection& d = shapes[i];
//        
//        for (auto i = 0; i < 68 ; i++) {
//            //TODO - check if coordindate to insert is within bounds of subdiv
//            subdiv.insert(toCv(d.part(i)));
//        }
//
//        draw_delaunay( image, subdiv, delaunay_color );
//    }
//}
//
//head_pose HeadPoseEstimation::pose(size_t face_idx, Mat image) const {
//
//    cv::Mat projectionMat = cv::Mat::zeros(3,3,CV_32F);
//    cv::Matx33f projection = projectionMat;
//    projection(0,0) = focalLength;
//    projection(1,1) = focalLength;
//    projection(0,2) = opticalCenterX;
//    projection(1,2) = opticalCenterY;
//    projection(2,2) = 1;
//
//    std::vector<Point3f> head_points;
//
//    head_points.push_back(P3D_SELLION);
//    head_points.push_back(P3D_RIGHT_EYE);
//    head_points.push_back(P3D_LEFT_EYE);
//    head_points.push_back(P3D_RIGHT_EAR);
//    head_points.push_back(P3D_LEFT_EAR);
//    head_points.push_back(P3D_MENTON);
//    head_points.push_back(P3D_NOSE);
//    head_points.push_back(P3D_STOMMION);
//
//    std::vector<Point2f> detected_points;
//
//    detected_points.push_back(coordsOf(face_idx, SELLION));
//    detected_points.push_back(coordsOf(face_idx, RIGHT_EYE));
//    detected_points.push_back(coordsOf(face_idx, LEFT_EYE));
//    detected_points.push_back(coordsOf(face_idx, RIGHT_SIDE));
//    detected_points.push_back(coordsOf(face_idx, LEFT_SIDE));
//    detected_points.push_back(coordsOf(face_idx, MENTON));
//    detected_points.push_back(coordsOf(face_idx, NOSE));
//
//    auto stomion = (coordsOf(face_idx, MOUTH_CENTER_TOP) + coordsOf(face_idx, MOUTH_CENTER_BOTTOM)) * 0.5;
//    detected_points.push_back(stomion);
//
//    cv::Mat rvec, tvec;
//
//    // Find the 3D pose of our head
//    solvePnP(head_points, detected_points,
//            projection, noArray(),
//            rvec, tvec, false,
//            cv::ITERATIVE);
//    Matx33d rotation;
//    Rodrigues(rvec, rotation);
//
//
//    cv::Matx44d pose = {
//        rotation(0,0),    rotation(0,1),    rotation(0,2),    tvec.at<double>(0)/1000,
//        rotation(1,0),    rotation(1,1),    rotation(1,2),    tvec.at<double>(1)/1000,
//        rotation(2,0),    rotation(2,1),    rotation(2,2),    tvec.at<double>(2)/1000,
//                    0,                0,                0,                     1
//    };
//
//    std::vector<Point2f> reprojected_points;
//
//    projectPoints(head_points, rvec, tvec, projection, noArray(), reprojected_points);
//
//    for (auto point : reprojected_points) {
//        circle(image, point,2, Scalar(0,255,255),2);
//    }
//
//    std::vector<Point3f> axes;
//    axes.push_back(Point3f(0,0,0));
//    axes.push_back(Point3f(50,0,0));
//    axes.push_back(Point3f(0,50,0));
//    axes.push_back(Point3f(0,0,50));
//    std::vector<Point2f> projected_axes;
//
//    projectPoints(axes, rvec, tvec, projection, noArray(), projected_axes);
//
//    line(image, projected_axes[0], projected_axes[3], Scalar(255,0,0),2,CV_AA);
//    line(image, projected_axes[0], projected_axes[2], Scalar(0,255,0),2,CV_AA);
//    line(image, projected_axes[0], projected_axes[1], Scalar(0,0,255),2,CV_AA);
//
//    // putText(image, "(" + to_string(int(pose(0,3) * 100)) + "cm, " + to_string(int(pose(1,3) * 100)) + "cm, " + to_string(int(pose(2,3) * 100)) + "cm)", coordsOf(face_idx, SELLION), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(0,0,255),2);
//
//	head_pose pose_head	=	{pose,	// transformation matrix
//							tvec,	// vector with translations
//							rvec};	// vector with rotations
//
//    return pose_head;
//}
//
//std::vector<head_pose> HeadPoseEstimation::poses(Mat image) const {
//
//    std::vector<head_pose> res;
//
//    for (auto i = 0; i < faces.size(); i++){
//        res.push_back(pose(i, image));
//    }
//
//    return res;
//
//}
//
//Point2f HeadPoseEstimation::coordsOf(size_t face_idx, FACIAL_FEATURE feature) const {
//    return toCv(shapes[face_idx].part(feature));
//}
//
//// Finds the intersection of two lines, or returns false.
//// The lines are defined by (o1, p1) and (o2, p2).
//// taken from: http://stackoverflow.com/a/7448287/828379
//bool HeadPoseEstimation::intersection(Point2f o1, Point2f p1, Point2f o2, Point2f p2,
//                                      Point2f &r) const {
//    Point2f x = o2 - o1;
//    Point2f d1 = p1 - o1;
//    Point2f d2 = p2 - o2;
//
//    float cross = d1.x*d2.y - d1.y*d2.x;
//    if (abs(cross) < /*EPS*/1e-8)
//        return false;
//
//    double t1 = (x.x * d2.y - x.y * d2.x)/cross;
//    r = o1 + d1 * t1;
//    return true;
//}
//
//// Draw a single point
//void HeadPoseEstimation::draw_point( Mat& img, Point2f fp, Scalar color ) {
//    circle( img, fp, 2, color, CV_FILLED, CV_AA, 0 );
//}
//
//// Draw delaunay triangles
//void HeadPoseEstimation::draw_delaunay( Mat& img, Subdiv2D& subdiv, Scalar delaunay_color ) {
//
//    std::vector<Vec6f> triangleList;
//    subdiv.getTriangleList(triangleList);
//    std::vector<Point> pt(3);
//    Size size = img.size();
//    Rect rect(0,0, size.width, size.height);
//
//    for( size_t i = 0; i < triangleList.size(); i++ )
//    {
//        Vec6f t = triangleList[i];
//        pt[0] = Point(cvRound(t[0]), cvRound(t[1]));
//        pt[1] = Point(cvRound(t[2]), cvRound(t[3]));
//        pt[2] = Point(cvRound(t[4]), cvRound(t[5]));
//        
//        // Draw rectangles completely inside the image.
//        if ( rect.contains(pt[0]) && rect.contains(pt[1]) && rect.contains(pt[2]))
//        {
//            line(img, pt[0], pt[1], delaunay_color, 1, CV_AA, 0);
//            line(img, pt[1], pt[2], delaunay_color, 1, CV_AA, 0);
//            line(img, pt[2], pt[0], delaunay_color, 1, CV_AA, 0);
//        }
//    }
//}
