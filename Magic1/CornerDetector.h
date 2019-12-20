//
//  CornerDetector.h
//  JScan
//
//  Created by SoftEng on 8/20/12.
//  Copyright (c) 2012 SoftEng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CornerDetector : NSObject
{
    CGPoint* p1;
    CGPoint* p2;
    CGPoint* p3;
    CGPoint* p4;
    
    int imgCX;
    int imgCY;
    
    float thumbCX;
    float thumbCY;
    
    cv::vector<cv::Point2f> corners;
    
    CvPoint2D32f JeffCorner[250];
    int maxCorners;
}

@property(nonatomic, retain) UIImage* inputImg;
@property(nonatomic, assign) CGSize screenSize;

-(void)startDetect:(UIImage*)inputImg withP1:(CGPoint*)p1 withP2:(CGPoint*)p2 withP3:(CGPoint*)p3 withP4:(CGPoint*)p4;

@end
