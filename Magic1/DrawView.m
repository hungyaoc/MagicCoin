//
//  DrawView.m
//  TestDrawLayer
//
//  Created by Jeff on 9/16/12.
//  Copyright (c) 2012 Jeff. All rights reserved.
//

#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>

#define CircleCX    100
#define CircleCY    100

@implementation DrawView
@synthesize delegate2;

- (id)initWithFrame:(CGRect)rc
{
    self = [super initWithFrame:rc];
    if (self)
    {
    }
    return self;
}


-(void)setCornerPos:(int)index withDX:(float)dx withDY:(float)dy
{
    switch (index)
    {
        case 1:
            imageRect1 = CGRectMake(imageRect1.origin.x + dx, imageRect1.origin.y + dy, CircleCX, CircleCY);
            p1 = CGPointMake(imageRect1.origin.x + CircleCX/2, imageRect1.origin.y + CircleCY/2);
            break;
            
        case 2:
            imageRect2 = CGRectMake(imageRect2.origin.x + dx, imageRect2.origin.y + dy, CircleCX, CircleCY);
            p2 = CGPointMake(imageRect2.origin.x + CircleCX/2, imageRect2.origin.y + CircleCY/2);
            break;
            
        case 3:
            imageRect3 = CGRectMake(imageRect3.origin.x + dx, imageRect3.origin.y + dy, CircleCX, CircleCY);
            p3 = CGPointMake(imageRect3.origin.x + CircleCX/2, imageRect3.origin.y + CircleCY/2);
            break;
            
        case 4:
            imageRect4 = CGRectMake(imageRect4.origin.x + dx, imageRect4.origin.y + dy, CircleCX, CircleCY);
            p4 = CGPointMake(imageRect4.origin.x + CircleCX/2, imageRect4.origin.y + CircleCY/2);
            break;
            
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

-(void)setAllPoint:(CGPoint)pt1 withP2:(CGPoint)pt2 withP3:(CGPoint)pt3 withP4:(CGPoint)pt4
{
    p1 = pt1;
    p2 = pt2;
    p3 = pt3;
    p4 = pt4;
    
    imageRect1 = CGRectMake(p1.x-CircleCX/2, p1.y-CircleCY/2, CircleCX, CircleCY);
    imageRect2 = CGRectMake(p2.x-CircleCX/2, p2.y-CircleCY/2, CircleCX, CircleCY);
    imageRect3 = CGRectMake(p3.x-CircleCX/2, p3.y-CircleCY/2, CircleCX, CircleCY);
    imageRect4 = CGRectMake(p4.x-CircleCX/2, p4.y-CircleCY/2, CircleCX, CircleCY);
    
    if(imgView1 == nil)
    {
        circleImage = [UIImage imageNamed:@"Circle-128.png"];
        
        imgView1        = [[UIImageView alloc] initWithFrame:imageRect1];
        imgView1.image  = circleImage;
        
        imgView2        = [[UIImageView alloc] initWithFrame:imageRect2];
        imgView2.image  = circleImage;
        
        imgView3        = [[UIImageView alloc] initWithFrame:imageRect3];
        imgView3.image  = circleImage;
        
        imgView4        = [[UIImageView alloc] initWithFrame:imageRect4];
        imgView4.image  = circleImage;
        
        [self addSubview:imgView1];
        [self addSubview:imgView2];
        [self addSubview:imgView3];
        [self addSubview:imgView4];
    }
    else
    {
        imgView1.frame = imageRect1;
        imgView2.frame = imageRect2;
        imgView3.frame = imageRect3;
        imgView4.frame = imageRect4;
    }
    
    [self setClipsToBounds:YES];
    [self setNeedsDisplay];
}

void drawStripes (void *info, CGContextRef con)
{
    // assume 4 x 4 cell
    CGContextSetFillColorWithColor(con, [[UIColor redColor] CGColor]);
    CGContextFillRect(con, CGRectMake(0,0,4,4));
    CGContextSetFillColorWithColor(con, [[UIColor blueColor] CGColor]);
    CGContextFillRect(con, CGRectMake(0,0,4,2));
}

/*
 void SetPatternColorSpace(CGContextRef context)
 {
 CGColorSpaceRef myColorSpace = CGColorSpaceCreatePattern(NULL);
 CGContextSetFillColorSpace(context, myColorSpace);
 CGColorSpaceRelease(myColorSpace);
 }
 
 void MyPatternFunction(void* info, CGContextRef context)
 {
 CGRect* patternBoundaries = (CGRect*)info;
 float myFillColor[] = {1,0,0,1}; //red;
 
 CGContextSaveGState(context);
 
 CGContextSetRGBFillColor(context, 0,1,1,1);
 CGContextFillRect(context, *patternBoundaries);
 CGContextSetFillColor(context, myFillColor);
 CGContextFillEllipseInRect(context, *patternBoundaries);
 
 CGContextFillPath(context);
 CGContextRestoreGState(context);
 }
 
 void PaintMyPattern(CGContextRef context, CGRect targetRect)
 {
 CGPatternCallbacks callbacks = { 0, &MyPatternFunction, NULL };
 CGContextSaveGState(context);
 CGPatternRef myPattern;
 SetPatternColorSpace(context);
 
 CGRect patternRect = CGRectMake(0,0,32,32);
 myPattern = CGPatternCreate((void*)&patternRect,
 targetRect,
 CGAffineTransformMake(1, 0, 0, 1, 0, 0),
 32,
 32,
 kCGPatternTilingConstantSpacing,
 true,
 &callbacks
 );
 float alpha = 1;
 CGContextSetFillPattern(context, myPattern, &alpha);
 CGPatternRelease(myPattern);
 //CGContextFillRect(context, targetRect);
 
 CGContextFillPath(context);
 CGContextRestoreGState(context);
 }
 */


-(void)fillPattern:(CGContextRef)ctx
{
    UIColor *tileColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripes.png"]];
    
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGColorRef tileCGColor = [tileColor CGColor];
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(tileCGColor);
    CGContextSetFillColorSpace(ctx, colorSpace);
    
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelPattern)
    {
        CGFloat alpha = 1.0f;
        CGContextSetFillPattern(ctx, CGColorGetPattern(tileCGColor), &alpha);
    }
    else
    {
        CGContextSetFillColor(ctx, CGColorGetComponents(tileCGColor));
    }
    
    CGContextFillPath(ctx);
    CGColorSpaceRelease(colorSpace);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // dash line
    CGFloat dashArray[] = {2,2,2,2};
    CGContextSetLineDash(context, 0, dashArray, 4);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextAddLineToPoint(context, p4.x, p4.y);
    CGContextAddLineToPoint(context, p3.x, p3.y);
    CGContextAddLineToPoint(context, p1.x, p1.y);
    
    CGContextStrokePath(context);
    
    imgView1.frame = imageRect1;
    imgView2.frame = imageRect2;
    imgView3.frame = imageRect3;
    imgView4.frame = imageRect4;
    
}

-(CGPoint)getPoint:(int)index
{
    switch (index)
    {
        case 1:
            return p1;
            break;
            
        case 2:
            return p2;
            break;
            
        case 3:
            return p3;
            break;
            
        case 4:
            return p4;
            break;
    }
    
    CGPoint pt = CGPointMake(0, 0);
    return pt;
}

-(void)callDelegateBegin
{
    if(delegate2)
    {
        //debug
        //NSLog(@"DrawView touchesBegan");
        
        [delegate2 dragBegin];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    ptStart = [touch locationInView:touch.view];
    
    // check if click on circle rect
    if(CGRectContainsPoint(imageRect1, ptStart))
    {
        [self callDelegateBegin];
        
        selImgIndex = 1;
    }
    else if(CGRectContainsPoint(imageRect2, ptStart))
    {
        [self callDelegateBegin];
        
        selImgIndex = 2;
    }
    else if(CGRectContainsPoint(imageRect3, ptStart))
    {
        [self callDelegateBegin];
        
        selImgIndex = 3;
    }
    else if(CGRectContainsPoint(imageRect4, ptStart))
    {
        [self callDelegateBegin];
        
        selImgIndex = 4;
    }
    else
        selImgIndex = 0;
    
    //NSLog(@"Touch x:%.0f y:%.0f => selImgIndex:%d", ptStart.x, ptStart.y, selImgIndex);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch* touch = [[event allTouches] anyObject];
    //CGPoint ptMove = [touch locationInView:touch.view];
    
    UITouch* touch = [touches anyObject];
    CGPoint ptMove = [touch locationInView:self];
    
    if(selImgIndex != 0)
    {
        float dx = (ptMove.x - ptStart.x);// * fZoomScale;
        float dy = (ptMove.y - ptStart.y);// * fZoomScale;
        
        //NSLog(@"selImgIndex:%d x:%d y:%d fZoomScale:%f", selImgIndex, dx, dy, fZoomScale);
        
        [self setCornerPos:selImgIndex withDX:dx withDY:dy];
        
        ptStart = ptMove;
        
        //debug
        //NSLog(@"DrawView touchesMoved");
        //if(delegate2)
        //    [delegate2 dragMove];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(selImgIndex != 0 && delegate2)
    {
        selImgIndex = 0;
        
        //debug
        //NSLog(@"DrawView touchesEnded");
        
        [delegate2 dragEnd];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*if(selImgIndex != 0 && delegate2)
     {
     //debug
     NSLog(@"DrawView touchesCancelled");
     
     [delegate2 dragEnd];
     }*/
}

-(void)setZoom:(float)zoom
{
    fZoomScale = zoom;
}

-(void)dealloc
{
    [imgView1 release];
    [imgView2 release];
    [imgView3 release];
    [imgView4 release];
    
    [super dealloc];
}

@end
