//
//  SettingViewCtrl.m
//  Magic1
//
//  Created by Jeff Chen on 1/31/13.
//  Copyright (c) 2013 Jeff Chen. All rights reserved.
//

#import "SettingViewCtrl.h"
#import "DraggableImage.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OutlineViewCtrl.h"
#import "UIImage+Resize.h"
#import "SplashViewCtrl.h"

@interface SettingViewCtrl ()

@end


@implementation SettingViewCtrl
@synthesize indicate1;
@synthesize indicate2;
@synthesize indicate3;
@synthesize btn1;
@synthesize btn2;
@synthesize btn3;
@synthesize myPreviewBig, myPreviewSmall;
@synthesize imgCard;
@synthesize indexStr;
@synthesize imgCoin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadSetting];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goClose:(id)sender
{
    [self saveSetting];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)go20:(id)sender
{
    index = 1;
    
    [self setupObjImage];
}

- (IBAction)goQuarter:(id)sender
{
    index = 2;
    
    [self setupObjImage];
}

- (IBAction)goBCard:(id)sender
{
    index = 3;
    
    [self setupObjImage];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0: // camera
            [self goCamera];
            break;
            
        case 1: // album
            [self goAlbum];
            break;
            
        case 2: // cancel
            cardChange = NO;
            break;
    }
}

-(void)goCamera
{
    isBackground = NO;
    
    UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = NO;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypeCamera;
    
    /*UIImage* img = [UIImage imageNamed:@"overlaygraphic.png"];
    UIImageView* imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
    imgView.frame = CGRectMake(57, 60, 205, 360);
    imgView.backgroundColor = [UIColor clearColor];*/
    
    imgPicker.showsCameraControls = YES;
    //imgPicker.cameraOverlayView = imgView;
    //===
    
    [self presentViewController:imgPicker animated:YES completion:nil];
}

-(void)goAlbum
{
    isBackground = NO;
    
    UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = NO;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
}


- (IBAction)goSelectBG:(id)sender
{
    isBackground = YES;
    
    UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = NO;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imgPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)img
                  editingInfo:(NSDictionary *)editInfo
{
    float x = img.size.width;
    float y = img.size.height;
    float ratio = y / x;
    
    x = 320;
    y = x * ratio;
    
    // smaller image
    CGSize size = CGSizeMake(x, y);
    UIImage* imgSmall = [img resizedImage:size interpolationQuality:kCGInterpolationHigh];
    
    //====
    [self dismissViewControllerAnimated:NO completion:nil];
    [picker release];
    
    if(isBackground == YES)
    {
        bgChange = YES;
        self.myPreviewBig.image = img;
    }
    else
    {
        switch (index)
        {
            case 1:
                break;
                
            case 2:
            {
                coinChange = YES;
                
                //===
                UIImage* imgMask    = [UIImage imageNamed:@"maskCoin.png"];
                UIImage* coinImg  =  [self getImage:imgSmall withMask:imgMask];
                
                //debug
                //UIImageWriteToSavedPhotosAlbum(coinImg, nil, nil, nil);
                //NSLog(@"%f %f",coinImg.size.width, coinImg.size.height);
                
                //
                CGRect fromRect = CGRectMake(75, 155, 170, 170); // or whatever rectangle
                CGImageRef drawImage = CGImageCreateWithImageInRect(coinImg.CGImage, fromRect);
                UIImage* newImage = [UIImage imageWithCGImage:drawImage];
                CGImageRelease(drawImage);
                
                //UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
                
                // save coin image
                self.imgCoin = newImage;
                
                [self setupObjImage];
            }
            break;
                
            case 3:
            {
                cardChange = YES;
                
                // pass to dialog
                OutlineViewCtrl* dlg = [[OutlineViewCtrl alloc] init];
                dlg.isInsert    = NO;
                dlg.inputImg    = imgSmall;
                dlg.parent      = self;
                
                [self presentViewController:dlg animated:YES completion:^{}];
                
                [dlg release];
            }
            break;
        }
    }
}

- (UIImage*) getImage:(UIImage *)image withMask:(UIImage*)maskImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef maskImageRef = [maskImage CGImage];
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    //CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, 200, 200, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat ratio = 0;
    ratio = maskImage.size.width/ image.size.width;
    
    if (ratio * image.size.height < maskImage.size.height)
    {
        ratio = maskImage.size.height/ image.size.height;
    }
    
    CGRect rect1  = {{0, 0}, {maskImage.size.width, maskImage.size.height}};
    CGRect rect2  = {{-((image.size.width*ratio)-maskImage.size.width)/2 , -((image.size.height*ratio)-maskImage.size.height)/2},
        {image.size.width*ratio, image.size.height*ratio}};
    
    //CGRect rect1  = {{58 , 140}, {200, 200}};
    //CGRect rect2  = {{58 , 140}, {200, 200}};
    
    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    CGContextDrawImage(mainViewContentContext, rect2, image.CGImage);
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
}


-(void)saveSetting
{
    if(bgChange == YES)
    {
        NSString* bigFile   = [NSString stringWithFormat:@"%@/Documents/bgBig.png", NSHomeDirectory()];
        NSData* bigData     = UIImagePNGRepresentation(self.myPreviewBig.image);
        [bigData  writeToFile:bigFile  atomically:YES];
    }
    
    // card image
    if(cardChange == YES)
    {
        NSString* cardFile = [NSString stringWithFormat:@"%@/Documents/card.png", NSHomeDirectory()];
        NSData* cardData = UIImagePNGRepresentation(self.imgCard);
        [cardData writeToFile:cardFile atomically:YES];
    }
    
    if(coinChange == YES)
    {
        NSString* cardFile = [NSString stringWithFormat:@"%@/Documents/coin.png", NSHomeDirectory()];
        NSData* coinData = UIImagePNGRepresentation(self.imgCoin);
        [coinData writeToFile:cardFile atomically:YES];
    }
    
    //=== setting file
    switch (index)
    {
        case 1:
            self.indexStr = INDEX_PAPER;
            break;
            
        case 2:
            self.indexStr = INDEX_COIN;
            break;
            
        case 3:
            self.indexStr = INDEX_CARD;
            break;
            
    }
    
    NSString* settingFile   = [NSString stringWithFormat:@"%@/Documents/setting.txt", NSHomeDirectory()];
    [self.indexStr writeToFile:settingFile atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

-(void)loadSetting
{
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    // 1. background image
    NSString* bigFile   = [NSString stringWithFormat:@"%@/Documents/bgBig.png", NSHomeDirectory()];
    if([mgr fileExistsAtPath:bigFile])
    {
        self.myPreviewBig.image = [UIImage imageWithContentsOfFile:bigFile];
    }
    else
    {
        // default
        self.myPreviewBig.image = [UIImage imageNamed:@"bg.png"];
    }
    
    // 2. coin image
    NSString* coinFile = [NSString stringWithFormat:@"%@/Documents/coin.png", NSHomeDirectory()];
    if([mgr fileExistsAtPath:coinFile])
    {
        self.imgCoin = [[UIImage alloc] initWithContentsOfFile:coinFile];
    }
    else
    {
        // default
        self.imgCoin = [UIImage imageNamed:@"Quarter.png"];
    }

    // 3. card image
    NSString* cardFile = [NSString stringWithFormat:@"%@/Documents/card.png", NSHomeDirectory()];    
    if([mgr fileExistsAtPath:cardFile])
    {
        self.imgCard = [[UIImage alloc] initWithContentsOfFile:cardFile];
    }
    else
    {
        // default
        self.imgCard = [UIImage imageNamed:@"card.png"];
    }
    
    //=== setting file
    NSString* settingFile   = [NSString stringWithFormat:@"%@/Documents/setting.txt", NSHomeDirectory()];
    if([mgr fileExistsAtPath:settingFile])
    {
        self.indexStr = [[NSString alloc] initWithContentsOfFile:settingFile encoding:NSASCIIStringEncoding error:nil];
    }
    else
    {
        self.indexStr = INDEX_COIN;
    }
    
    // convert to index
    if([self.indexStr isEqualToString:INDEX_PAPER])
        index = 1;
    else if([self.indexStr isEqualToString:INDEX_COIN])
        index = 2;
    else
        index = 3;
    
    
    // setup obj image
    [self setupObjImage];
}

-(void)setupObjImage
{
    switch (index)
    {
        case 1:
        {
            // 20 dollar
            self.myPreviewSmall.image = [UIImage imageNamed:@"20.jpg"];
            
            self.indicate1.image = [UIImage imageNamed:@"Red.png"];
            self.indicate2.image = nil;
            self.indicate3.image = nil;

        }
        break;
            
        case 2:
        {
            // quarter
            self.myPreviewSmall.image = self.imgCoin;
            
            [btn2 setBackgroundImage:self.imgCoin forState:UIControlStateNormal];
            
            self.indicate1.image = nil;
            self.indicate2.image = [UIImage imageNamed:@"Red.png"];
            self.indicate3.image = nil;
        }
        break;
            
        case 3:
        {
            // BCard
            self.myPreviewSmall.image = self.imgCard;
            
            [btn3 setBackgroundImage:self.imgCard forState:UIControlStateNormal];
            
            self.indicate1.image = nil;
            self.indicate2.image = nil;
            self.indicate3.image = [UIImage imageNamed:@"Red.png"];
        }
        break;
    }
}

 #define DegreesToRadians(x) (M_PI * x / 180.0)
- (IBAction)goDemoVideo:(id)sender
{
    NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"MOV"];
    NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
    
    moviePlayerController = [[[MPMoviePlayerController alloc] initWithContentURL:fileURL] retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayerController];
    
    // Rotate 90 degrees to hide it off screen
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, DegreesToRadians(90));
    moviePlayerController.view.transform = rotationTransform;
    
    // adjust video to full screen
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat cx = screenRect.size.width;
    CGFloat cy = screenRect.size.height;
    
    moviePlayerController.view.frame =  CGRectMake(0, 0, cx, cy);
    
    [self.view addSubview:moviePlayerController.view];
    
    moviePlayerController.fullscreen = NO;
    
    //moviePlayerController.controlStyle = MPMovieControlStyleNone;
    //moviePlayerController.scalingMode = MPMovieScalingModeFill;
    
    [moviePlayerController play];

}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    //MPMoviePlayerController *moviePlayerController = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerController];
    
    
    [moviePlayerController.view removeFromSuperview];
    [moviePlayerController release];
}

-(void)changeCard:(UIImage*)img
{
    // save image
    NSString* cardFile = [NSString stringWithFormat:@"%@/Documents/card.png", NSHomeDirectory()];
    [UIImagePNGRepresentation(img) writeToFile:cardFile atomically:YES];
    
    // save setting
    //self.indexStr = INDEX_CARD;
    //NSString* settingFile   = [NSString stringWithFormat:@"%@/Documents/setting.txt", NSHomeDirectory()];
    //[self.indexStr  writeToFile:settingFile atomically:YES encoding:NSASCIIStringEncoding error:nil];

    // assign
    self.imgCard = img;
    index = 3;
    
    // update
    [self setupObjImage];
}


- (IBAction)goChangePaper:(id)sender
{
    [self go20:nil];
}

- (IBAction)goChangeCoin:(id)sender
{
    [self goQuarter:nil];
    
    UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = NO;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypeCamera;
    
    imgPicker.showsCameraControls = YES;
    imgPicker.cameraOverlayView = self.viewCoinMask; //imgView;
    //===
    
    [self presentViewController:imgPicker animated:YES completion:nil];
}

- (IBAction)goChangeCard:(id)sender;
{
    [self goBCard:nil];
    
    isBackground = NO;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // ask user to confirm
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select Input"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Camera", @"Album", nil];
        
        //sheet.tag = 300;
        [sheet showInView:self.view];
        
        [sheet release];
    }
    else
    {
        [self goAlbum];
    }
}

- (IBAction)goInfo:(id)sender
{
    SplashViewCtrl* dlg = [[[SplashViewCtrl alloc] init] autorelease];
    
    dlg.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:dlg animated:YES completion:^{}];
}

-(void)dealloc
{
    [self.myPreviewBig   release];
    [self.myPreviewSmall release];
    
    [self.imgCard   release];
    [self.indexStr  release];
    [self.imgCoin   release];
    
    [self.viewCoinMask release];
    
    [super dealloc];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
