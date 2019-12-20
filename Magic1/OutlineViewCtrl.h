//
//  OutlineViewCtrl.h
//  TestCamera2
//
//  Created by SoftEng on 8/13/12.
//  Copyright (c) 2012 SoftEng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableImage.h"
#import "DrawView.h"
//#import "FingerPaintView.h"


#define JPG_COMP_RATIO      0.1
//#define JPG_COMP_RATIO_01   0.1
//#define JPG_COMP_RATIO_05   0.5

@protocol OutlineViewCtrlDelegate <NSObject>
-(void)imageReady:(UIImage*)image withName:(NSString*)docName withFolder:(NSString*)folderName;
@end


@class ViewController;
@class SettingViewCtrl;

enum SelImageSize {LARGE, MEDIUM, SMALL};
enum SegSelect {COLOR, GRAY, BW};

@interface OutlineViewCtrl : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, DrawViewDelegate>
{
    //====
    IBOutlet UIActivityIndicatorView* waitCursor1;
    IBOutlet DrawView* myDrawLayer;
    
    IBOutlet UIButton* btnNext;
    IBOutlet UIView* viewTool;
    IBOutlet UIView* viewAdjust;
    
    IBOutlet UILabel* lblPreview;
    
    IBOutlet UIScrollView *myScroll;
    
    // outline
    IBOutlet UIScrollView *outlineScroll;
    IBOutlet UIView* outlineView;
    
    // testing
    IBOutlet UIView* viewBlack;
    IBOutlet UIActivityIndicatorView* waitCursor;
    IBOutlet UIImageView* lightBar;
    IBOutlet UIProgressView* progView;
    int nProgress; // 0 ~ 100
     
    
    IBOutlet UIButton* btnOld;
    IBOutlet UIButton* btnColor;
    IBOutlet UIButton* btnGray;
    IBOutlet UIButton* btnBW;
    
    // resize outline
    IBOutlet UIButton* btnResize;
    BOOL bResizeFull;
    BOOL bFirstAnimate;   //for animate light bar
    int nCurSelectAdjust;
    
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    CGPoint p4;
    
    float minX;
    float maxX;
    float minY;
    float maxY;
    
    CGFloat cx, cy;
    
    float screenCX;
    float screenCY;
    
    int imgCX;
    int imgCY;
    
    int brightValue; // 0~255
    int noiseValue;  // 0~255
    
    float histR;
    float histG;
    float histB;
    int   histAvg;
    
    // thumb image
    enum SegSelect segSelect;
    
    UIImage* imgLarge;
    
    UIImage* cacheColor;
    UIImage* cacheBW;
    UIImage* cacheGray;
    
    enum SelImageSize selImageSize; // 1: large, 2: medium, 3:small
    
}

@property(nonatomic, assign) SettingViewCtrl* parent;
@property(nonatomic, retain) IBOutlet UIImageView* myImgView;
@property(nonatomic, retain) IBOutlet UIImageView* myImgView2;

@property(nonatomic, retain) UIImage* inputImg;
@property(nonatomic, retain) IBOutlet UIButton *btnOutput;

//@property(nonatomic, retain) id<OutlineViewCtrlDelegate>delegate2;
@property(nonatomic, assign) BOOL isInsert;

@property (retain, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet UIButton *btnSign;
//@property (retain, nonatomic) IBOutlet FingerPaintView *fingerView;
@property (retain, nonatomic) IBOutlet UIView *penColorView;
@property (retain, nonatomic) IBOutlet UIView *penSizeView;



-(IBAction)goNext:(id)sender;
-(IBAction)goClose:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)goOutput:(id)sender;

-(IBAction)goAdjust1:(id)sender;


-(IBAction)goLeftTurn:(id)sender;
-(IBAction)goRightTurn:(id)sender;

-(IBAction)ToggleResize:(id)sender;

-(IBAction)valueChanged:(UISlider*)sender;


- (void)threadProgress;
- (void)threadWait:(BOOL)bHide;

@end
