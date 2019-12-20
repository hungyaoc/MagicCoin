//
//  CornerDetector.m
//  JScan
//
//  Created by SoftEng on 8/20/12.
//  Copyright (c) 2012 SoftEng. All rights reserved.
//

#import "CornerDetector.h"
#import "UIImage+Resize.h"
#import "UIImage+OpenCV.h"
#import <opencv2/opencv.hpp>

#define thumbRatio 2

@implementation CornerDetector
@synthesize inputImg;
@synthesize screenSize;


-(void)getLTCorner
{
    int dist = sqrt(imgCX * imgCX + imgCY * imgCY);
    
    int x1 = 20/thumbRatio;
    int y1 = 60/thumbRatio;
    
    
    for( int i = 0; i < maxCorners ; i++ )
    {
        int x = JeffCorner[i].x;
        int y = JeffCorner[i].y;
        
        int tmp = sqrt((x-x1)*(x-x1) + (y-y1)*(y-y1));
        
        if(tmp < dist)
        {
            p1->x = x * thumbRatio;
            p1->y = y * thumbRatio;
            
            dist = tmp;
        }
    }
    
    //debug
    NSLog(@"LT: x:%f, y:%f", p1->x/thumbRatio, p1->y/thumbRatio);
    
    // set the limit .. can't small than half
    if(p1->x > (thumbCX/2.0)*thumbRatio)
        p1->x = (thumbCX/2.0)*thumbRatio;
    
    if(p1->y > (thumbCY/2.0)*thumbRatio)
        p1->y = (thumbCY/2.0)*thumbRatio;
}

-(void)getRTCorner
{
    int dist = sqrt(imgCX * imgCX + imgCY * imgCY);
    
    float x1 = thumbCX - 20/thumbRatio;
    float y1 = 60/thumbRatio;
    
    for( int i = 0; i < maxCorners ; i++ )
    {
        int x = JeffCorner[i].x;
        int y = JeffCorner[i].y;
        
        int tmp = sqrt((x-x1)*(x-x1) + (y-y1)*(y-y1));
        
        if(tmp < dist)
        {
            p2->x = x * thumbRatio;
            p2->y = y * thumbRatio;
            
            dist = tmp;
        }
    }
    
    //debug
    NSLog(@"RT: x:%f, y:%f", p2->x/thumbRatio, p2->y/thumbRatio);
    
    // set the limit .. can't small than half
    if(p2->x < thumbCX/2.0)
        p2->x = thumbCX/2.0;
    
    if(p2->y > thumbCY/2.0)
        p2->y = thumbCY/2.0;
}

-(void)getLBCorner
{
    int dist = sqrt(imgCX * imgCX + imgCY * imgCY);
    
    int x1 = 20/thumbRatio;
    int y1 = thumbCY - 60/thumbRatio;
    
    for( int i = 0; i < maxCorners; i++ )
    {
        int x = JeffCorner[i].x;
        int y = JeffCorner[i].y;
        
        int tmp = sqrt((x-x1)*(x-x1) + (y-y1)*(y-y1));
        
        if(tmp < dist)
        {
            p3->x = x * thumbRatio;
            p3->y = y * thumbRatio;
            
            dist = tmp;
        }
    }
    
    //debug
    NSLog(@"LB: x:%f, y:%f", p3->x/thumbRatio, p3->y/thumbRatio);
    
    // set the limit .. can't small than half
    if(p3->x > (thumbCX/2.0)*thumbRatio)
        p3->x = (thumbCX/2.0)*thumbRatio;
    
    if(p3->y < (thumbCY/2.0)*thumbRatio)
        p3->y = (thumbCY/2.0)*thumbRatio;
}

-(void)getRBCorner
{
    int dist = sqrt(imgCX * imgCX + imgCY * imgCY);
    
    int x1 = thumbCX - 20/thumbRatio;
    int y1 = thumbCY - 60/thumbRatio;
    
    for( int i = 0; i < maxCorners; i++ )
    {
        int x = JeffCorner[i].x;
        int y = JeffCorner[i].y;
        
        int tmp = sqrt((x-x1)*(x-x1) + (y-y1)*(y-y1));
        
        if(tmp < dist)
        {
            p4->x = x * thumbRatio;
            p4->y = y * thumbRatio;
            
            dist = tmp;
        }
    }
    
    //debug
    NSLog(@"RB: x:%f, y:%f", p4->x/thumbRatio, p4->y/thumbRatio);
    
    // set the limit .. can't small than half
    if(p4->x < (thumbCX/2.0)*thumbRatio)
        p4->x = (thumbCX/2.0)*thumbRatio;
    
    if(p4->y < (thumbCY/2.0)*thumbRatio)
        p4->y = (thumbCY/2.0)*thumbRatio;
}



-(void)createCornerPointsArray:(UIImage*)image
{
    // adaptive
    IplImage* inImg     = [UIImage CreateIplImageFromUIImage:image];
    IplImage* grayImg   = cvCreateImage(cvGetSize(inImg), inImg->depth, 1);
    IplImage* debugImg  = cvCreateImage(cvGetSize(inImg), inImg->depth, 3);
    
    // 1. convert to gray
    cvCvtColor(inImg, grayImg, CV_RGB2GRAY);
    
    // 2. smooth
    cvSmooth(grayImg, grayImg, CV_GAUSSIAN, 3, 3);
    
    
    // canny edge detection
    //cvCanny(grayImg, grayImg, 70, 100); // the smaller the number, the more detail show on image
    
    // corner detection
    //cvCornerMinEigenVal(grayImg, cornerImg, 3);
    //cvPreCornerDetect(grayImg, cornerImg, 3);
    //cvCornerHarris(grayImg, cornerImg, 5, 3, 0.04);
    //cvConvertScale(cornerImg, grayImg);
    
    
    
    //=====
    maxCorners = 150; //25
    double qualityLevel = 0.04;
    double minDistance = 5; //0
    int block_size = 3;
    int use_harris = 0;
    double k = 0.04;
    
    // must use gray image to track
    cvGoodFeaturesToTrack(grayImg, grayImg, nil, JeffCorner, &maxCorners, qualityLevel, minDistance, nil,
                          block_size, use_harris, k);
    
    
    // save output
    /*cvCvtColor(grayImg, debugImg, CV_GRAY2RGB);
    
     for( int i = 0; i < maxCorners; i++ )
     {
         int x = JeffCorner[i].x;
         int y = JeffCorner[i].y;
         
         NSLog(@"%d: %d %d", i, x, y);
         
         [self setPixelColor:debugImg withX:x withY:y-1];
         [self setPixelColor:debugImg withX:x withY:y+1];
         [self setPixelColor:debugImg withX:x withY:y];
         [self setPixelColor:debugImg withX:x-1 withY:y];
         [self setPixelColor:debugImg withX:x+1 withY:y];
         [self setPixelColor:debugImg withX:x+1 withY:y+1];
         [self setPixelColor:debugImg withX:x-1 withY:y-1];
         [self setPixelColor:debugImg withX:x-1 withY:y+1];
         [self setPixelColor:debugImg withX:x+1 withY:y-1];
     }
     
     UIImage* imgOut1 = [UIImage UIImageFromIplImage:debugImg];
     NSString* pngPath1 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Debug.png"];
     [UIImagePNGRepresentation(imgOut1) writeToFile:pngPath1 atomically:YES];*/
       
    
    // release
    cvReleaseImage(&inImg);
    cvReleaseImage(&grayImg);
    cvReleaseImage(&debugImg);
}

-(void)setPixelColor:(IplImage*)debugImg withX:(int)x withY:(int)y
{
    uchar* ptr = (uchar*)(debugImg->imageData + y * debugImg->widthStep);
    
    ptr[3*x+0] = 255;
    ptr[3*x+1] = 0;
    ptr[3*x+2] = 255;
}

-(void)startDetect:(UIImage*)image
            withP1:(CGPoint*)imgP1
            withP2:(CGPoint*)imgP2
            withP3:(CGPoint*)imgP3
            withP4:(CGPoint*)imgP4
{
    p1 = imgP1;
    p2 = imgP2;
    p3 = imgP3;
    p4 = imgP4;
    
    // create thumb image
    thumbCX = screenSize.width / thumbRatio;
    thumbCY = screenSize.height/ thumbRatio;
    
    //NSLog(@"thumbCX:%f, thumbCY:%f", thumbCX, thumbCY);
    
    imgCX  = image.size.width;
    imgCY  = image.size.height;
    
    UIImage* thumbImg = [image resizedImage:CGSizeMake(thumbCX, thumbCY) interpolationQuality:kCGInterpolationHigh];
    
    [self createCornerPointsArray:thumbImg];
    
    [self getLTCorner];
    [self getRTCorner];
    [self getLBCorner];
    [self getRBCorner];
}


-(void)dealloc
{
    [inputImg release];
    inputImg = nil;

    [super dealloc];
}
@end
