//
//  DrawView.h
//  TestDrawLayer
//
//  Created by Jeff on 9/16/12.
//  Copyright (c) 2012 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawViewDelegate <NSObject>

-(void)dragBegin;
-(void)dragMove;
-(void)dragEnd;

@end

@interface DrawView : UIView
{
    CGPoint p1, p2, p3, p4;
    
    float fZoomScale;
    
    CGRect imageRect1;
    CGRect imageRect2;
    CGRect imageRect3;
    CGRect imageRect4;
    
    //UIImage* bgImage;
    
    UIImage* circleImage;
    
    UIImageView* imgView1;
    UIImageView* imgView2;
    UIImageView* imgView3;
    UIImageView* imgView4;
    
    
    int selImgIndex;
    
    CGPoint ptStart;
}

@property(nonatomic, assign) id<DrawViewDelegate> delegate2;

-(CGPoint)getPoint:(int)index;


-(void)setAllPoint:(CGPoint)pt1 withP2:(CGPoint)pt2 withP3:(CGPoint)pt3 withP4:(CGPoint)pt4;

-(void)setZoom:(float)zoom;

@end
