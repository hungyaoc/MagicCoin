//
//  OutlineViewCtrl.m
//  TestCamera2
//
//  Created by SoftEng on 8/13/12.
//  Copyright (c) 2012 SoftEng. All rights reserved.
//

#import "OutlineViewCtrl.h"

#import "AppDelegate.h"
#import "ViewController.h"
#import "CornerDetector.h"
#import "UIImage+Resize.h"
#import "UIImage+OpenCV.h"
#import <QuartzCore/QuartzCore.h>

#import "SettingViewCtrl.h"

//#define SAVE_FILE 1

#define TAG_NEWTITLE    100
#define THUMB_RATIO     1


// globl variable
IplImage* imageTBGray   = nil;
IplImage* imageTBColor  = nil;


@interface OutlineViewCtrl ()

@end

@implementation OutlineViewCtrl
@synthesize parent;
@synthesize inputImg;
@synthesize myImgView;
@synthesize myImgView2;


-(void)getHist:(IplImage*)imgColor withR:(float*)valueB withG:(float*)valueG withB:(float*)valueR
{
    *valueR = *valueG = *valueB = 0;
    
    CvScalar scale = cvAvg(imgColor);
    
    *valueR = scale.val[2];
    *valueG = scale.val[1];
    *valueB = scale.val[0];
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)createScrollView
{
    myScroll.contentSize = self.myImgView2.frame.size;
    
    myScroll.delegate = self;
    myScroll.minimumZoomScale = 1;
    myScroll.maximumZoomScale = 10.0;
    [myScroll setZoomScale:myScroll.minimumZoomScale];
}

-(void)adjustScrollView
{
    myScroll.contentSize = self.myImgView2.frame.size;
    
    myScroll.delegate = self;
    myScroll.minimumZoomScale = 1;
    myScroll.maximumZoomScale = 10.0;
    [myScroll setZoomScale:myScroll.minimumZoomScale];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView == outlineScroll)
    {
        return outlineView;
    }
    else
    {
        return self.myView;
    }
}

- (void)threadDetectCorner
{
    p1 = CGPointMake(0, 0);
    p2 = CGPointMake(0, 0);
    p3 = CGPointMake(0, 0);
    p4 = CGPointMake(0, 0);
    
    // corner detect
    CornerDetector* detector = [[CornerDetector alloc] init];
    
    detector.screenSize = self.myImgView.bounds.size;
    [detector startDetect:self.myImgView.image withP1:&p1 withP2:&p2 withP3:&p3 withP4:&p4];
    
    // animation
    [myDrawLayer setAllPoint:p1 withP2:p2 withP3:p3 withP4:p4];
    myDrawLayer.delegate2 = self;
    
    [detector release];
}

- (void)setupDrawLayer
{
    //setup begin position
    CGRect rc = myDrawLayer.frame;
    int x = rc.origin.x;
    int y = rc.origin.y;
    int dx = rc.size.width;
    int dy = rc.size.height;
    
    CGPoint pt1 = CGPointMake(x,      y);
    CGPoint pt2 = CGPointMake(x+dx,   y);
    CGPoint pt3 = CGPointMake(x,      y+dy);
    CGPoint pt4 = CGPointMake(x+dx,   y+dy);
    
    [myDrawLayer setAllPoint:pt1 withP2:pt2 withP3:pt3 withP4:pt4];
}

BOOL bFirstOutline = YES;
-(void)viewDidAppear:(BOOL)animated
{
    if(bFirstOutline == YES)
    {
        bFirstOutline = NO;
        [self threadDetectCorner];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myImgView.image = self.inputImg;
    
    bResizeFull = NO;
    
    bFirstOutline = YES;
    
    //[self performSelector:@selector(threadDetectCorner) withObject:nil afterDelay:0.3];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)getMaxMin
{
    minX = p1.x;
    maxX = p1.x;
    minY = p1.y;
    maxY = p1.y;
    
    // get minX
    if(p2.x < minX)
        minX = p2.x;
    
    if(p3.x < minX)
        minX = p3.x;
    
    if(p4.x < minX)
        minX = p4.x;
    
    // get maxX
    if(p2.x > maxX)
        maxX = p2.x;
    
    if(p3.x > maxX)
        maxX = p3.x;
    
    if(p4.x > maxX)
        maxX = p4.x;
    
    // get minY
    if(p2.y < minY)
        minY = p2.y;
    
    if(p3.y < minY)
        minY = p3.y;
    
    if(p4.y < minY)
        minY = p4.y;
    
    // get maxY
    if(p2.y > maxY)
        maxY = p2.y;
    
    if(p3.y > maxY)
        maxY = p3.y;
    
    if(p4.y > maxY)
        maxY = p4.y;
    
    //
    float dUp   = sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y));
    float dDown = sqrt((p4.x - p3.x)*(p4.x - p3.x) + (p4.y - p3.y)*(p4.y - p3.y));
    float fRotate = dDown / dUp;
    
    //===
    cx = (int)(maxX - minX);
    cy = (int)((maxY - minY) * fRotate);
    
    //debug
    //NSLog(@"getMaxMin: cx:%.1f cy:%.1f", cx, cy);
}

// x: 0~cx
// y: 0~cy
-(CGPoint)getConvertPt:(int)x withY:(int)y
{
    CGPoint ptRet;
    CGPoint ptUp, ptDown;
    
    CGFloat rx = (float)x/cx;
    CGFloat ry = (float)y/cy;
    
    // get 4 middle point
    ptUp.x = p1.x + (p2.x - p1.x) * rx;
    ptUp.y = p1.y + (p2.y - p1.y) * rx;
    
    ptDown.x = p3.x + (p4.x - p3.x) * rx;
    ptDown.y = p3.y + (p4.y - p3.y) * rx;
    
    // get final point
    ptRet.x = ptUp.x + (ptDown.x - ptUp.x) * ry;
    ptRet.y = ptUp.y + (ptDown.y - ptUp.y) * ry;
    
    //NSLog(@"%.1f %.1f", ptRet.x, ptRet.y);
    
    return ptRet;
}


-(UIImage*)createRectImage:(UIImage*)image
{
NSDate* d1 = [NSDate date];
    
    CGImageRef imageRef = [image CGImage];
    
    int width    = image.size.width;
    int height   = image.size.height;
    //NSLog(@"createRectImage: width:%d height:%d %d=> cx:%f, cy:%f", width, height, image.imageOrientation, cx, cy);
    
    //===
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *rawData      = (unsigned char *)malloc(width * height * 4);
    unsigned char *rawDataColor = (unsigned char *)malloc(cx * cy * 4);
    
    NSUInteger bytesPerPixel    = 4;
    NSUInteger bytesPerRow      = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    // create input image array
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    //int oldProgress = 0;
    
    
    //for(int y=0; y<cy; y++)
    dispatch_apply(cy, dispatch_get_global_queue(0, 0), ^(size_t y)
    {
        //for(int x=0; x<cx; x++)
        dispatch_apply(cx, dispatch_get_global_queue(0, 0), ^(size_t x)
        {
            CGPoint newPt = [self getConvertPt:x withY:y];
            
            int index1 = (bytesPerRow * (int)newPt.y) + ((int)newPt.x * bytesPerPixel);
            int index2 = (4 * cx * y) + (x * bytesPerPixel);
            
            // assign
            rawDataColor[index2+0]   = rawData[index1+0];
            rawDataColor[index2+1]   = rawData[index1+1];
            rawDataColor[index2+2]   = rawData[index1+2];
            rawDataColor[index2+3]   = rawData[index1+3];
    
        });
        
        //update UI
        /*nProgress = y*100/cy;
        
        //if(oldProgress != nProgress)
        {
            //oldProgress = nProgress;
            
            [self performSelectorInBackground:@selector(threadProgress) withObject:nil];
        }*/
    });
    
    // create output image
    CGContextRef ctx = CGBitmapContextCreate(rawDataColor,
                                             cx,
                                             cy,
                                             8,
                                             cx * bytesPerPixel,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedLast );
    
    CGImageRef imageRef2 = CGBitmapContextCreateImage (ctx);
	UIImage* imgTmp = [UIImage imageWithCGImage:imageRef2];
    
    CGColorSpaceRelease(colorSpace);
	CGContextRelease(ctx);
    CGImageRelease(imageRef2);
	
	free(rawData);
    free(rawDataColor);
    rawData = rawDataColor = nil;
    
NSDate* d2 = [NSDate date];
NSTimeInterval dd = [d2 timeIntervalSinceDate:d1];
NSLog(@"createRectImage:%f", dd);
    
    return imgTmp;
}

-(void) createThumbImage:(UIImage*)image
{
    int x = image.size.width;
    int y = image.size.height;
    
    // 1. create color image
    UIImage* smallImg = [image resizedImage:CGSizeMake(x/THUMB_RATIO, y/THUMB_RATIO) interpolationQuality:kCGInterpolationHigh];
    
    imageTBColor = [UIImage CreateIplImageFromUIImage:smallImg];
    
    //====
    if(imageTBGray != nil)
    {
        cvReleaseImage(&imageTBGray);
        imageTBGray = nil;
    }
    
    imageTBGray = cvCreateImage(cvGetSize(imageTBColor), imageTBColor->depth, 1);
    
    // 1. convert to gray
    cvCvtColor(imageTBColor, imageTBGray, CV_RGB2GRAY);
}



- (void) threadProgress
{
    if(bFirstAnimate == YES)
    {
        float nY = screenCY * nProgress/100.0 + 40;
    
        lightBar.center = CGPointMake(screenCX/2, nY);
    }
    else
    {
        //NSLog(@"nProgress:%d", nProgress);
        
        CGRect rc = myScroll.frame;
        float nY = rc.origin.y + rc.size.height * nProgress/100.0;
        
        lightBar.center = CGPointMake(screenCX/2, nY);
        
        [self.view addSubview:lightBar];
    }
        
    if(nProgress >= 98)
        lightBar.hidden = YES;
    else
        lightBar.hidden = NO;
    
    //lblProgress.text = [NSString stringWithFormat:@"%d%%", nProgress];
}

- (void) threadProgressThumb
{
    progView.progress = nProgress/100.0;
}

-(IBAction)ToggleResize:(id)sender
{
    if(bResizeFull == NO)
    {
        bResizeFull = YES;
        
        [self setupDrawLayer];
        [btnResize setBackgroundImage:[UIImage imageNamed:@"resize_shrink.png"] forState:UIControlStateNormal];
    }
    else
    {
        bResizeFull = NO;
        
        [self performSelector:@selector(threadDetectCorner) withObject:nil afterDelay:0.1];
        
        [btnResize setBackgroundImage:[UIImage imageNamed:@"resize_full.png"] forState:UIControlStateNormal];
    }
}



- (void)threadWait1
{
    waitCursor1.hidden = NO;
}

-(IBAction)goNext:(id)sender
{
    bFirstAnimate = YES;
    
    // show waitcursor
    [self performSelectorInBackground:@selector(threadWait1) withObject:nil];
    
    p1 = [myDrawLayer getPoint:1];
    p2 = [myDrawLayer getPoint:2];
    p3 = [myDrawLayer getPoint:3];
    p4 = [myDrawLayer getPoint:4];
    
    // careful... the image size is rotate
    int originalCX   = self.myImgView.image.size.width;
    int originalCY   = self.myImgView.image.size.height;
    
    screenCX = self.myImgView.bounds.size.width; 
    screenCY = self.myImgView.bounds.size.height;
    
    
    float fX = originalCX / screenCX;
    float fY = originalCY / screenCY;
    
    //=== adjust
    p1.x = p1.x * fX;
    p1.y = p1.y * fY;
    
    p2.x = p2.x * fX;
    p2.y = p2.y * fY;
    
    p3.x = p3.x * fX;
    p3.y = p3.y * fY;
    
    p4.x = p4.x * fX;
    p4.y = p4.y * fY;
    
    [self getMaxMin];
    
    // process
    UIImage* imgRotate = [self.myImgView.image resizedImage:CGSizeMake(originalCX/1, originalCY/1)
                                  interpolationQuality:kCGInterpolationHigh];
    
    
    // create thumb image
    imgLarge = [[self createRectImage:imgRotate] retain];
    //[self createThumbImage:imgLarge];
    
    //debug
    NSLog(@"imgLarge: %.0f %.0f", imgLarge.size.width, imgLarge.size.height);
    
    // show preview dialog
    viewAdjust.frame = self.view.frame;
    self.myImgView2.image = imgLarge;
    
    [self.view addSubview:viewAdjust];
        
    // make the image view zoomable
    [self adjustScrollView];
    
    // hide wait cursor
    waitCursor1.hidden = YES;
}

#pragma mark
#pragma mark slider
-(IBAction)valueChanged:(UISlider*)sender
{
    // show waitcursor
    //[self performSelectorInBackground:@selector(threadWait1) withObject:NO];
    
    float value = sender.value;
    
    NSLog(@"%f", value);
    
    self.myImgView2.image = [self changeBright:imgLarge withValue:value];
    
    waitCursor1.hidden = YES;
}

-(UIImage*)changeBright:(UIImage*)img withValue:(float)newValue
{
    IplImage* inImg  = [UIImage CreateIplImageFromUIImage:img];
    
    // adjust contrast
    cvCvtScale(inImg, inImg, newValue, 0);
    
    // output
    UIImage* tmpImg = [UIImage UIImageFromIplImage:inImg];
    
    cvReleaseImage(&inImg);
    
    return tmpImg;
}


-(IBAction)goOutput:(id)sender
{
    [self.parent changeCard:self.myImgView2.image];
        
    // close
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)goClose:(id)sender
{
    // close
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark adjust image
/*-(void)createGrayImage:(IplImage*)inImg
{
    if(imageTBGray != nil)
    {
        cvReleaseImage(&imageTBGray);
        imageTBGray = nil;
    }
        
    imageTBGray = cvCreateImage(cvGetSize(inImg), inImg->depth, 1);
    
    // 1. convert to gray
    cvCvtColor(inImg, imageTBGray, CV_RGB2GRAY);
}*/

-(void)adjustWhiteBalance:(IplImage*)imgColor withR:(IplImage*)ImgR withG:(IplImage*)ImgG  withB:(IplImage*)ImgB
{
    CvScalar scale = cvAvg(imgColor);
    
    int tmpR = scale.val[0];
    int tmpG = scale.val[1];
    int tmpB = scale.val[2];
    
    if(tmpR >= tmpG && tmpR >= tmpB)
    {
        cvConvertScale(ImgG, ImgG, 1.0, tmpR - tmpG);
        cvConvertScale(ImgB, ImgB, 1.0, tmpR - tmpB);
    }
    else if(tmpG >= tmpB && tmpG >= tmpR)
    {
        cvConvertScale(ImgR, ImgR, 1.0, tmpG - tmpR);
        cvConvertScale(ImgB, ImgB, 1.0, tmpG - tmpB);
    }
    else
    {
        cvConvertScale(ImgR, ImgR, 1.0, tmpB - tmpR);
        cvConvertScale(ImgG, ImgG, 1.0, tmpB - tmpG);
    }
}

#pragma mark
#pragma mark adjust color
-(void)adjustColorSize:(IplImage*)inImg withOut:(IplImage*)outImg withB:(int)WSize withC:(int)cValue
          withBegin:(int)begin  // light bar start position
         withLength:(int)length // light bat move length
{
    int width  = inImg->width;
    int height = inImg->height;
    
    //int oldProgress = 0;
    
    // 1. get avg image
    IplImage* meanImg = cvCreateImage(cvGetSize(inImg), inImg->depth, 3);

NSDate* d1 = [NSDate date];
    
    //cvSmooth(inImg, meanImg, CV_BLUR, WSize, WSize);
    cv::Mat src = cv::cvarrToMat(inImg);
    cv::Mat dst0 = cv::cvarrToMat(meanImg), dst = dst0;
    cv::boxFilter( src, dst, dst.depth(), cv::Size(WSize, WSize));
    
NSDate* d2 = [NSDate date];
NSTimeInterval dd = [d2 timeIntervalSinceDate:d1];
NSLog(@"cvSmooth:%f", dd);

    /*uchar tab[256*2];
    
    for( int i = 0; i < 256*2; i++ )
    {
        tab[i] = (uchar)(i> 255-cValue ? 255:0);
    }
    
    for( int y = 0; y < height; y++ )
    {
        const   uchar* sdata = (uchar*)(inImg->imageData   + inImg->widthStep   * y);
        const   uchar* mdata = (uchar*)(meanImg->imageData + meanImg->widthStep * y);
        uchar* ddata = (uchar*)(outImg->imageData  + outImg->widthStep  * y);

        for( int x = 0; x < width*3; x+=3)
        {
            int tmp1 = tab[sdata[x+0] - mdata[x+0] + 255];
            int tmp2 = tab[sdata[x+1] - mdata[x+1] + 255];
            int tmp3 = tab[sdata[x+2] - mdata[x+2] + 255];
            
            ddata[x+0] = tmp1;
            ddata[x+1] = tmp2;
            ddata[x+2] = tmp3;
        }
    }*/


    dispatch_apply(height, dispatch_get_global_queue(0, 0), ^(size_t y)
    {
        const   uchar* sdata = (uchar*)(inImg->imageData   + inImg->widthStep   * y);
        const   uchar* mdata = (uchar*)(meanImg->imageData + meanImg->widthStep * y);
        uchar* ddata = (uchar*)(outImg->imageData  + outImg->widthStep  * y);
        
        
        //GCD
        //for( int x = 0; x < width*3; x+=3)
        dispatch_apply(width, dispatch_get_global_queue(0, 0), ^(size_t x)
        {
            int x1 = x*3;
            int pixel[3];
            
            pixel[0] =  sdata[x1+0] - (mdata[x1+0] - cValue);
            pixel[1] =  sdata[x1+1] - (mdata[x1+1] - cValue);
            pixel[2] =  sdata[x1+2] - (mdata[x1+2] - cValue);
            
            //for(int k=0; k<3; k++)
            //dispatch_apply(3, dispatch_get_global_queue(0, 0), ^(size_t k)
            {
                /*if(sdata[x1+k] > mdata[x1 +k] - cValue)
                {
                    int tmp = sdata[x1+k] + pixel[k] * 10;
                    ddata[x1+k] = tmp > 255 ? 255 : tmp;
                }
                else
                {
                    int tmp = sdata[x1+k] + pixel[k]*4;
                    ddata[x1+k] =  tmp > 0 ? tmp : 0;
                }*/
                
                if(sdata[x1+0] > mdata[x1 +0] - cValue)
                {
                    int tmp = sdata[x1+0] + pixel[0] * 10;
                    ddata[x1+0] = tmp > 255 ? 255 : tmp;
                }
                else
                {
                    int tmp = sdata[x1+0] + pixel[0]*4;
                    ddata[x1+0] =  tmp > 0 ? tmp : 0;
                }
                
                //
                if(sdata[x1+1] > mdata[x1 +1] - cValue)
                {
                    int tmp = sdata[x1+1] + pixel[1] * 10;
                    ddata[x1+1] = tmp > 255 ? 255 : tmp;
                }
                else
                {
                    int tmp = sdata[x1+1] + pixel[1]*4;
                    ddata[x1+1] =  tmp > 0 ? tmp : 0;
                }
                
                //
                if(sdata[x1+2] > mdata[x1 +2] - cValue)
                {
                    int tmp = sdata[x1+2] + pixel[2] * 10;
                    ddata[x1+2] = tmp > 255 ? 255 : tmp;
                }
                else
                {
                    int tmp = sdata[x1+2] + pixel[2]*4;
                    ddata[x1+2] =  tmp > 0 ? tmp : 0;
                }
            }
        });
    });
    
    cvReleaseImage(&meanImg);
    
    bFirstAnimate = NO;
    
}

-(UIImage*)adjustColorThumbImage:(IplImage*)imgColor
{
    NSDate* d1 = [NSDate date];
    
    CvSize size = cvGetSize(imgColor);
    IplImage* outImg  = cvCreateImage(size, 8, 3);
    
    //=====
    int blockSize = 41;//15;
    int cValue = 22; // the bigger number, more brighter
    
    [self adjustColorSize:imgColor withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
    
    //debug
    NSLog(@"color blockSize: %d, cValue: %d", blockSize, cValue);
    
    // adjust contrast
    //cvConvertScale(outImg, outImg, 1.1, 0);
    
    // output
    UIImage* imgRet = [UIImage UIImageFromIplImage:outImg];
    cvReleaseImage(&outImg);
        
    
    NSDate* d2 = [NSDate date];
    NSTimeInterval dd = [d2 timeIntervalSinceDate:d1];
    NSLog(@"color time interval:%f", dd);
    
    return imgRet;
}





#pragma mark
#pragma mark adjust BW
-(void)adjustBWSize:(IplImage*)inImg withOut:(IplImage*)outImg withB:(int)WSize withC:(int)cValue
          withBegin:(int)begin  // light bar start position
         withLength:(int)length // light bat move length
{
    int width  = inImg->width;
    int height = inImg->height;

    //int oldProgress = 0;
    
    // 1. get avg image
    IplImage* meanImg = cvCreateImage(cvGetSize(inImg), inImg->depth, 1);
    
NSDate* d1 = [NSDate date];
    
    cvSmooth(inImg, meanImg, CV_BLUR, WSize, WSize);
    
NSDate* d2 = [NSDate date];
NSTimeInterval dd = [d2 timeIntervalSinceDate:d1];
NSLog(@"cvSmooth:%f", dd);
    
    
    
    /*uchar tab[768] = {0};
    
    for( int i = 0; i < 768; i++ )
    {
        tab[i] = (uchar)(i > 255 - cValue ? 255 : 0);
    }*/
    
   
    /*for( int y = 0; y < height; y++ )
   {
       const   uchar* sdata = (uchar*)(inImg->imageData   + inImg->widthStep   * y);
       const   uchar* mdata = (uchar*)(meanImg->imageData + meanImg->widthStep * y);
       uchar* ddata = (uchar*)(outImg->imageData  + outImg->widthStep  * y);
       
       for( int x = 0; x < width; x++)
      {
          //ddata[x] = tab[sdata[x] - mdata[x] + 255];
          
          if(sdata[x] > mdata[x] - cValue)
          {
              int r3 =  sdata[x] + (sdata[x] - (mdata[x] - cValue)) * 10;//10;
              {
                  ddata[x] = r3 > 255 ? 255 : r3;
              }
          }
          else
          {
              int r3 =  sdata[x] - ((mdata[x] - cValue) - sdata[x]) * 4;
              
              ddata[x] =  r3 < 0 ? 0 : r3;
          }
      }
   }*/
    
    //for( int y = 0; y < height; y++ )
    dispatch_apply(height, dispatch_get_global_queue(0, 0), ^(size_t y)
    {
        const   uchar* sdata = (uchar*)(inImg->imageData   + inImg->widthStep   * y);
        const   uchar* mdata = (uchar*)(meanImg->imageData + meanImg->widthStep * y);
                uchar* ddata = (uchar*)(outImg->imageData  + outImg->widthStep  * y);
        
        //for( int x = 0; x < width; x++)
        dispatch_apply(width, dispatch_get_global_queue(0, 0), ^(size_t x)
        {
            //ddata[x] = tab[sdata[x] - mdata[x] + 255];
            
            if(sdata[x] > mdata[x] - cValue)
            {
                int r3 =  sdata[x] + (sdata[x] - (mdata[x] - cValue)) * 10;//10;
                {
                    ddata[x] = r3 > 255 ? 255 : r3;
                }
            }
            else
            {
                int r3 =  sdata[x] - ((mdata[x] - cValue) - sdata[x]) * 4;
                
                ddata[x] =  r3 < 0 ? 0 : r3;
            }
        });
    });
    
    cvReleaseImage(&meanImg);
    
    bFirstAnimate = NO;
    
}


-(UIImage*)adjustBWThumbImage:(IplImage*)grayImg
{
NSDate* d1 = [NSDate date];
    
    CvSize size = cvGetSize(grayImg);
    
    IplImage* outImg   = cvCreateImage(size, 8, 1);
    CvScalar scalar;
    scalar.val[0] = 255;
    cvSet(outImg, scalar);
    
    //debug
#ifdef SAVE_FILE
    UIImage* img = [UIImage UIImageFromIplImage:grayImg];
    NSString* pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imgGray.png"];
    [UIImagePNGRepresentation(img) writeToFile:pngPath atomically:YES];
#endif
    
    // 1. get the histogram
    scalar = cvAvg(grayImg);
    int hist = scalar.val[0];
    
    int blockSize   = 41;
    int cValue      = 22; // the bigger, the brighter
    
    [self adjustBWSize:grayImg withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
    
    /*switch (nCurSelectAdjust)
    {
        case 1:
            blockSize = 51;
            cValue = 20;
             [self adjustBWSize:grayImg withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
            break;
            
        case 2: 
            blockSize = 41;
            cValue = 23;
             [self adjustBWSize:grayImg withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
            break;
            
        case 3:
            blockSize = 31;
            cValue = 24;
            [self adjustBWSize:grayImg withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
            break;
            
        case 4:
            blockSize = 21;
            cValue = 25;
             [self adjustBWSize:grayImg withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
            break;
            
        case 5:
            blockSize = 19;
            cValue = 26;
            [self adjustBWSize:grayImg withOut:outImg withB:blockSize withC:cValue withBegin:0 withLength:100];
            break;
            
    }*/
    
    NSLog(@"hist:%d => blockSize:%d cValue:%d", hist, blockSize, cValue);
    
    // adjust contrast
    //cvConvertScale(outImg, outImg, 1.1, 0);
    
    //output
    UIImage* imgRet = [UIImage UIImageFromIplImage:outImg];
        
#ifdef SAVE_FILE
        NSString* file = [NSString stringWithFormat:@"Documents/B%d_C%d.png", blockSize, cValue];
        pngPath = [NSHomeDirectory() stringByAppendingPathComponent:file];
        [UIImagePNGRepresentation(imgRet) writeToFile:pngPath atomically:YES];
#endif
   
    
    // 4. clean
    /*[self removeNoiseColor:outImg withOutImg:outImg withWSize:5];
     
     #ifdef SAVE_FILE
     imgRet = [UIImage UIImageFromIplImage:outImg];
     pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imgClean.png"];
     [UIImagePNGRepresentation(imgRet) writeToFile:pngPath atomically:YES];
     #endif*/
    
    cvReleaseImage(&outImg);
    outImg = nil;
    
NSDate* d2 = [NSDate date];
NSTimeInterval dd = [d2 timeIntervalSinceDate:d1];
NSLog(@"BW interval:%f", dd);
    
    return imgRet;
}



-(void)hideWaitCursor
{
   // waitCursor.hidden = YES;
    viewBlack.hidden = YES;
}

-(IBAction)goAdjust1:(id)sender
{
    nCurSelectAdjust = 1;
    
    if(segSelect == COLOR)
    {
        if(cacheColor == nil)
        {
            cacheColor = [[self adjustColorThumbImage:imageTBColor] retain];
        }
        
        self.myImgView2.image = cacheColor;
    }
    else if(segSelect == BW)
    {
        if(cacheBW == nil)
        {
            cacheBW = [[self adjustBWThumbImage:imageTBGray] retain];
        }
        
        self.myImgView2.image = cacheBW;
    }
}



- (void)threadWait:(BOOL)bHide
{
    viewBlack.hidden = NO;
    
}

- (void)threadWaitLite
{
    viewBlack.hidden = NO;
}



// 1. check file name
-(int)isFileExist:(NSString*)fileName
{
    // filename can't contain illegal char: or /
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ,.@_+-*/"] invertedSet];
    
    if ([fileName rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        NSString* msg = @"This string contains illegal characters";
        
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:msg
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] autorelease];
        
        [alert show];
        
        return 0;
    }
    
    //if ([aString isMatchedByRegex:@"[^a-zA-Z0-9]"])
      //  NSLog(@"This string contains illegal characters");
    
    
    NSString* fullPath = [NSString stringWithFormat:@"%@/Documents/%@.pdf", NSHomeDirectory(), fileName];
    
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    BOOL bRet = [mgr fileExistsAtPath:fullPath];
    
    if(bRet == YES)
        return 1;
    else
        return -1;
    
}

#pragma mark
#pragma mark left/right turn
-(IBAction)goLeftTurn:(id)sender
{
    //debug... show edge detection image
    /*NSString* pngPath1 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Debug.png"];
    NSData* data = [[[NSData alloc] initWithContentsOfFile:pngPath1] autorelease];
    UIImage* img = [UIImage imageWithData:data];
    self.myImgView.image = img;
    return;*/
    
    //
    UIImageOrientation NewDir   = UIImageOrientationUp;
    UIImageOrientation dir      = self.myImgView.image.imageOrientation;
    
    if(dir == UIImageOrientationUp)
        NewDir = UIImageOrientationLeft;
    else if(dir == UIImageOrientationLeft)
        NewDir = UIImageOrientationDown;
    else if(dir == UIImageOrientationDown)
        NewDir = UIImageOrientationRight;
    else if (dir == UIImageOrientationRight)
        NewDir = UIImageOrientationUp;
    
    
    self.myImgView.image = [UIImage imageWithCGImage:[self.myImgView.image CGImage] scale:1.0 orientation:NewDir];
    
    // adjust edge dection
    [self threadDetectCorner];
}

-(IBAction)goRightTurn:(id)sender
{
    UIImageOrientation NewDir   = UIImageOrientationUp;
    UIImageOrientation dir      = self.myImgView.image.imageOrientation;
    
    if(dir == UIImageOrientationUp)
        NewDir = UIImageOrientationRight;
    else if(dir == UIImageOrientationRight)
        NewDir = UIImageOrientationDown;
    else if(dir == UIImageOrientationDown)
        NewDir = UIImageOrientationLeft;
    else if (dir == UIImageOrientationLeft)
        NewDir = UIImageOrientationUp;
    
    self.myImgView.image = [UIImage imageWithCGImage:[self.myImgView.image CGImage] scale:1.0 orientation:NewDir];
    
    // adjust edge dection
    [self threadDetectCorner];
}



-(void)loadDebugImg
{
    NSString* pngPath1 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Debug.png"];
 
    UIImage* img = [UIImage imageWithContentsOfFile:pngPath1];
    
    self.myImgView.image = img;
}

#pragma mark
#pragma mark DrawView Delegate
-(void)dragBegin
{
    outlineScroll.scrollEnabled = NO;
}

-(void)dragMove
{
    
}

-(void)dragEnd
{
    outlineScroll.scrollEnabled = YES;
}

-(IBAction)goBack:(id)sender
{
    lightBar.center = CGPointMake(screenCX/2, -100);
    [viewAdjust removeFromSuperview];
}


- (void)didReceiveMemoryWarning
{
     NSLog(@"*** didReceiveMemoryWarning => OutlineViewCtrl");
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    [self setBtnOutput:nil];
    [self setBtnSign:nil];
    [self setMyView:nil];
    [self setPenColorView:nil];
    [self setPenSizeView:nil];
    
    [self setInputImg:nil];
    [self setMyImgView:nil];
    [self setMyImgView2:nil];
    
    //[self  setParent:nil];
    
    //===
    outlineScroll   = nil;
    outlineView     = nil;
    myScroll        = nil;
    
    myDrawLayer     = nil;
    //imgLarge        = nil;
    
    cacheColor      = nil;
    cacheBW         = nil;
    //cacheGray       = nil;
    
    //===
    viewBlack   = nil;
    waitCursor  = nil;
    lightBar    = nil;
    progView    = nil;
    
    btnOld      = nil;
    btnColor    = nil;
    btnGray     = nil;
    btnBW       = nil;
    btnResize   = nil;
    
    imageTBGray  = nil;
    imageTBColor = nil;
    
    viewAdjust = nil;
    
    [super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [_btnOutput     release];
    [_btnSign       release];
    [_myView        release];
    [_penColorView  release];
    [_penSizeView   release];
    
    // fix memory leaking
    [self.inputImg      release];
    [self.myImgView     release];
    [self.myImgView2    release];
    [outlineScroll      release];
    [outlineView        release];
    [myScroll           release];
    
    // corner detection
    [myDrawLayer release];
    
    [cacheColor release];
    [cacheBW    release];
    
    // ===
    [viewBlack  release];
    [waitCursor release];
    [lightBar   release];
    [progView   release];
    
    [btnOld     release];
    [btnColor   release];
    [btnGray    release];
    [btnBW      release];
    [btnResize  release];
    
    cvReleaseImage(&imageTBGray);
    cvReleaseImage(&imageTBColor);

    [viewAdjust release];
    
    [super dealloc];
}
@end


/*UIImage* image = ...; // An image
NSData* pixelData = (NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
void* pixelBytes = [pixelData bytes];

//Leaves only the green pixel, assuming 32-bit RGBA
for(int i = 0; i < [pixelData length]; i += 4) {
    bytes[i] = 0; // red
    bytes[i+1] = bytes[i+1]; // green
    bytes[i+2] = 0; // blue
    bytes[i+3] = 0; // alpha
}

NSData* newPixelData = [NSData dataWithBytes:pixelBytes length:[pixelData length]];
UIImage* newImage = [UIImage imageWithData:newPixelData];*/
