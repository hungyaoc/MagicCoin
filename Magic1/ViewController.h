//
//  ViewController.h
//  Magic1
//
//  Created by Jeff Chen on 1/23/13.
//  Copyright (c) 2013 Jeff Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableImage.h"
#import <CoreMotion/CoreMotion.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate , UIImagePickerControllerDelegate,
UIAccelerometerDelegate,
UIAccelerometerDelegate,
GADInterstitialDelegate>
{
    CGRect rcOld;
    
    CGPoint startLocation;
    
    BOOL bClick;
    
    BOOL isBackground;
    
    UIImageView* myObj;
    
    int index;
    
    // accelerometer
    BOOL bEnableAcceler;
    BOOL histeresisExcited;
    
    BOOL bEnableMagic; // safe lock
    
    //===
    UIDynamicAnimator*      _animator;
    UIGravityBehavior*      _gravity;
    UICollisionBehavior*    _collision;
    UIDynamicItemBehavior*  _elastic;
}

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (retain, nonatomic) IBOutlet UIImageView *myBackground;
@property (retain, nonatomic) IBOutlet UIImageView *my20;
@property (retain, nonatomic) IBOutlet UIImageView *myCard;
@property (retain, nonatomic) IBOutlet UIImageView *myQuarter;

@property (retain, nonatomic) IBOutlet UIButton *btn1;
@property (retain, nonatomic) IBOutlet UIButton *btn2;


- (IBAction)goSettings:(id)sender;

- (void)onBtn1Click;
- (void)onBtn2Click;

@end
