//
//  SplashViewCtrl.h
//  JScan
//
//  Created by Jeff Chen on 1/24/13.
//  Copyright (c) 2013 SoftEng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewCtrl : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIView* splash0;
    IBOutlet UIView* splash1;
    IBOutlet UIView* splash2;
    IBOutlet UIView* splash3;
    IBOutlet UIView* splash4;
}

@property (retain, nonatomic) IBOutlet UIScrollView *myScroll;
@property (retain, nonatomic) IBOutlet UIPageControl *myPageCtrl;

- (IBAction)goClose:(id)sender;
@end
