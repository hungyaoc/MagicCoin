//
//  ViewController.m
//  Magic1
//
//  Created by Jeff Chen on 1/23/13.
//  Copyright (c) 2013 Jeff Chen. All rights reserved.
//

#import "ViewController.h"
#import "SettingViewCtrl.h"
#import "SplashViewCtrl.h"

@import GoogleMobileAds;

@interface ViewController ()
@property(nonatomic, strong) GADInterstitial *admob;
@end

@implementation ViewController
@synthesize my20;
@synthesize myCard;
@synthesize myQuarter;

-(void)viewWillAppear:(BOOL)animated
{
    [self loadObject];
}

-(void)viewDidAppear:(BOOL)animated
{
    // check if file already exist mean it show before ... do nothing
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSString* srcPath = [NSString stringWithFormat:@"%@/Documents/splash.txt", NSHomeDirectory()];
    
    if([mgr fileExistsAtPath:srcPath])
    {
        bEnableAcceler = YES; // turn on the acceler
    }
    else
    {
        // show splash dialog
        //[self showSplash];
        
        // create the file
        NSString* str = @"Jeff";
        [str writeToFile:srcPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bEnableAcceler = NO; // turn off the power of acceler
    
    bEnableMagic = NO;
    
    [self initGravity];
    
    /*[self initAdmob];
    
    //
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"1.Double click to bring up setting page. 2.shake your device to see the magic"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];*/
}

-(void)initAdmob
{
    self.admob = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-7171184960888074/6382789543"];
    
    self.admob.delegate = self;
    
    GADRequest *request = [GADRequest request];
    
    [self.admob loadRequest:request];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if([self.admob isReady])
    {
        [self.admob presentFromRootViewController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark
#pragma mark detect shake
// Ensures the shake is strong enough on at least two axes before declaring it a shake.
// "Strong enough" means "greater than a client-supplied threshold" in G's.
-(void)showObject
{
    CGRect rc0 = myObj.frame;
    myObj.frame = CGRectMake(rc0.origin.x, rc0.origin.y, 0, 0);
    
    // click on space
    [self performSelector:@selector(shakeAction) withObject:nil afterDelay:1.1];
    
    // animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    
        myObj.alpha = 1.0;
        myObj.frame = rc0;
 
    [UIView commitAnimations];
}

/*BOOL IsShaking(UIAcceleration* last, UIAcceleration* current, double threshold)
{
	float
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    //NSLog(@"dx:%f dy:%f dz:%f", deltaX, deltaY, deltaZ);
    
	return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}*/


-(void)loadObject
{
    SettingViewCtrl* dlg = [[[SettingViewCtrl alloc] init] autorelease];
    [dlg loadSetting];
    
    //debug
    //NSLog(@"dlg.indexStr: %@", dlg.indexStr);
    
    if([dlg.indexStr isEqualToString:INDEX_PAPER])
    {
        index = 1;
        myObj = self.my20;
    }
    else if([dlg.indexStr isEqualToString:INDEX_COIN])
    {
        index = 2;
        
        self.myQuarter.image = dlg.imgCoin;
        myObj = self.myQuarter;
    }
    else
    {
        index = 3;
        
        self.myCard.image = dlg.imgCard;
        myObj = self.myCard;
    }
    
    myObj.alpha = 0.0;
    
    //background
    NSString* bigFile   = [NSString stringWithFormat:@"%@/Documents/bgBig.png", NSHomeDirectory()];
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    if([mgr fileExistsAtPath:bigFile])
    {
        self.myBackground.image = [UIImage imageWithContentsOfFile:bigFile];
    }
    else
    {
        // default
        self.myBackground.image = [UIImage imageNamed:@"bg.png"];
    }
}



- (IBAction)goReset:(id)sender
{
    //
    NSLog(@"goReset");
    
    switch (index)
    {
        case 1: // 20
            myObj.frame = CGRectMake(51, 33, 190, 330);
            break;
        
        case 2: // coin
            myObj.frame = CGRectMake(79, 114, 130, 130);
            break;
            
        case 3: // card
            myObj.frame = CGRectMake(12, 33, 297, 515);
            break;
        
    }
 
    myObj.alpha = 0.0;
    
    bClick = NO;
    
    // chage btn 2 status
    bEnableMagic = NO;
    self.btn2.alpha = 0.1;
}


#pragma mark
#pragma mark touch
-(void)doubleTap
{
    [self goSettings:nil];
}


- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = [touch tapCount];
    
    // Retrieve the touch point
    CGPoint pt = [touch locationInView:self.view];
    
    startLocation = pt;
    
    /*if(tapCount == 1)
    {
        CGRect rc1 = self.btn1.frame;
        CGRect rc2 = self.btn2.frame;
        
        if(CGRectContainsPoint(rc1, pt))
        {
            [self onBtn1Click];
            return;
        }
        else if(CGRectContainsPoint(rc2, pt))
        {
            [self onBtn2Click];
            return;
        }
        
    }
    else*/ if(tapCount == 2)
    {
        [self doubleTap];
    }
    
    
    // check if click on mycard
    CGRect frame = myObj.frame;
    
    if(CGRectContainsPoint(frame, pt))
    {
        // start to drag object
        bClick = YES;
        
        [self stopGravity];
    }
    else
    {
        // click on space
        //[self shakeAction];
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Move relative to the original touch point
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    if(bClick == YES)
    {
        CGRect frame = myObj.frame;
        

        frame.origin.x += pt.x - startLocation.x;
        frame.origin.y += pt.y - startLocation.y;
        
        myObj.frame = frame;
    
        //NSLog(@"%f %f", pt.x, frame.origin.x);
        
        startLocation.x = pt.x;
        startLocation.y = pt.y;
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // screen rect
    int cx = self.view.frame.size.width;
    int cy = self.view.frame.size.height;
    
    if(bClick == YES)
    {
        bClick = NO;
        
        //CGPoint pt = [[touches anyObject] locationInView:self.view];
        
        //NSLog(@"%d, %d", (int)pt.x, (int)pt.y);
        
        CGRect frame = myObj.frame;
        
        int x1 = frame.origin.x;
        int x2 = x1 + frame.size.width;
        
        int y1 = frame.origin.y;
        int y2 = y1 + frame.size.height;
        
        if(x1 < 0 || x2 > cx || y1 < 0 || y2 > cy)
        {
            //if(bEnableMagic)
            {
                [self goReset:nil];
            }
        }
        else
        {
            [self shakeAction];
        }
        
        /*if(pt.x > 300)
        {
            [self goReset:nil];
        }*/
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(bClick == YES)
    {
        bClick = NO;
        
        [self goReset:nil];
    }
}

- (void)onBtn1Click
{
    [self goSettings:nil];
}

- (void)onBtn2Click
{
    if(bEnableMagic)
    {
        bEnableMagic = NO;
        
        self.btn2.alpha = 0.0;
    }
    else
    {
        bEnableMagic = YES;
        
        self.btn2.alpha = 0.05;
    }
}


- (IBAction)goSettings:(id)sender
{
    bEnableAcceler = NO;
    
    [self goReset:nil];
    
    SettingViewCtrl* dlg = [[[SettingViewCtrl alloc] init] autorelease];
    
    [self presentViewController:dlg animated:YES completion:^{}];
}

#pragma mark
#pragma mark splash
-(void)showSplash
{
    // check if file already exist mean it show before ... do nothing
    /*NSFileManager* mgr = [NSFileManager defaultManager];
    NSString* srcPath = [NSString stringWithFormat:@"%@/Documents/splash.txt", NSHomeDirectory()];
    if([mgr fileExistsAtPath:srcPath])
        return;*/
    
    
    // show splash dialog
    SplashViewCtrl* dlg = [[SplashViewCtrl alloc] init];
    [self presentViewController:dlg animated:NO completion:^{}];
    
    // create the file
    //NSString* str = @"Jeff";
    //[str writeToFile:srcPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
}



- (void)viewDidUnload
{
    [self setMyQuarter:nil];
    [self setMyQuarter:nil];
    
    myObj = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [_myBackground release];
    
    [self.myCard release];
    [self.my20 release];
    [self.myQuarter release];
    [super dealloc];
}

#pragma mark
#pragma mark rotate
-(void)initGravity
{
    self.motionManager = [[CMMotionManager alloc] init];
    
    self.motionManager.accelerometerUpdateInterval = 0.1;
    self.motionManager.gyroUpdateInterval = 0.1;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];

}

-(void)stopGravity
{
    [_animator removeAllBehaviors];
}

-(void)shakeAction
{
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // gravity
    _gravity = [[UIGravityBehavior alloc] init];
    
    [_gravity addItem:myObj];
                
    
    [_animator addBehavior:_gravity];
    
    
    // collision
    _collision = [[UICollisionBehavior alloc] init];
    
    [_collision addItem:myObj];
    
    _collision.translatesReferenceBoundsIntoBoundary = YES;
    [_animator addBehavior:_collision];
    
    // plastic
    _elastic = [[UIDynamicItemBehavior alloc] initWithItems:@[myObj]];
    _elastic.elasticity = 0.1;
    _elastic.friction   = 0;
    _elastic.resistance = 0;
    _elastic.allowsRotation = YES;
    
    [_animator addBehavior:_elastic];
    
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        [self showObject];
    }
}


-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    //NSLog(@"%.1f %1f", acceleration.x, acceleration.y);
    
    if(_gravity)
    {
        CGVector vec;
        
        vec.dx = acceleration.x;
        vec.dy = -acceleration.y;
        
        _gravity.gravityDirection = vec;
    }
}

-(void)outputRotationData:(CMRotationRate)rotation
{
    //NSLog(@"%f", rotation.x);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
