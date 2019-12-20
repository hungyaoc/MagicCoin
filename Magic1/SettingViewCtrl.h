//
//  SettingViewCtrl.h
//  Magic1
//
//  Created by Jeff Chen on 1/31/13.
//  Copyright (c) 2013 Jeff Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDEX_PAPER   @"PAPER"
#define INDEX_COIN    @"COIN"
#define INDEX_CARD    @"CARD"

@class DraggableImage;
@class MPMoviePlayerController;

@interface SettingViewCtrl : UIViewController <
UINavigationControllerDelegate , UIImagePickerControllerDelegate,
UIActionSheetDelegate>
{
    BOOL isBackground;
    
    BOOL bgChange;
    BOOL cardChange;
    BOOL coinChange;
    
    MPMoviePlayerController *moviePlayerController;
    
    int index; // 1: 20 dollar, 2: quarter, 3: BCard
    
}


@property(nonatomic, retain) NSString* indexStr;
@property(nonatomic, retain) UIImage* imgCard;
@property(nonatomic, retain) UIImage* imgCoin;

@property(nonatomic, retain) IBOutlet UIView* viewCoinMask;

@property(nonatomic, retain) IBOutlet UIImageView* myPreviewBig;
@property(nonatomic, retain) IBOutlet DraggableImage* myPreviewSmall;

@property(nonatomic, retain) IBOutlet UIImageView* indicate1;
@property(nonatomic, retain) IBOutlet UIImageView* indicate2;
@property(nonatomic, retain) IBOutlet UIImageView* indicate3;

@property(nonatomic, retain) IBOutlet UIButton* btn1;
@property(nonatomic, retain) IBOutlet UIButton* btn2;
@property(nonatomic, retain) IBOutlet UIButton* btn3;

- (IBAction)goClose:(id)sender;

- (IBAction)go20:(id)sender;
- (IBAction)goQuarter:(id)sender;
- (IBAction)goBCard:(id)sender;

- (IBAction)goSelectBG:(id)sender;
- (IBAction)goDemoVideo:(id)sender;

-(void)loadSetting;

-(void)changeCard:(UIImage*)img;

- (IBAction)goChangePaper:(id)sender;
- (IBAction)goChangeCoin:(id)sender;
- (IBAction)goChangeCard:(id)sender;

- (IBAction)goInfo:(id)sender;

@end
