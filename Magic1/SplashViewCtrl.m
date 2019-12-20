//
//  SplashViewCtrl.m
//  JScan
//
//  Created by Jeff Chen on 1/24/13.
//  Copyright (c) 2013 SoftEng. All rights reserved.
//

#import "SplashViewCtrl.h"

@interface SplashViewCtrl ()

@end

@implementation SplashViewCtrl

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
    
    [self loadScroll];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"*** didReceiveMemoryWarning => splashViewCtrl");
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)goClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


-(void)loadScroll
{
    int cx = self.myScroll.frame.size.width;
    int cy = self.myScroll.frame.size.height;
    
    self.myScroll.contentSize = CGSizeMake(cx*5, cy);
    
    // add UIImageViewctrl to scroll
    splash0.frame = CGRectMake(0, 0, cx, cy);
    [self.myScroll addSubview:splash0];
    
    splash1.frame = CGRectMake(cx, 0, cx, cy);
    [self.myScroll addSubview:splash1];
    
    splash2.frame = CGRectMake(cx*2, 0, cx, cy);
    [self.myScroll addSubview:splash2];
    
    splash3.frame = CGRectMake(cx*3, 0, cx, cy);
    [self.myScroll addSubview:splash3];
    
    splash4.frame = CGRectMake(cx*4, 0, cx, cy);
    [self.myScroll addSubview:splash4];
    
    /*for(int i=0; i<5; i++)
    {
        UIImageView* imgV1 = [[UIImageView alloc] init];
        
        imgV1.contentMode = UIViewContentModeScaleAspectFit;
        imgV1.frame = CGRectMake(cx*i, 0, cx, cy);
        
        NSString* str = [NSString stringWithFormat:@"splash%d.jpg", i];
        imgV1.image = [UIImage imageNamed:str];
        
        [self.myScroll addSubview:imgV1];
        [imgV1 release];
    }*/
    
    
    //set default to page1
    self.myPageCtrl.numberOfPages = 5;
    self.myPageCtrl.currentPage   = 0;
}



#pragma mark
#pragma mark ScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.myScroll.frame.size.width;
    
    int page = floor((self.myScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.myPageCtrl.currentPage = page;
}

- (void)viewDidUnload
{
    splash0 = nil;
    splash1 = nil;
    splash2 = nil;
    splash3 = nil;
    splash4 = nil;
    
    [self setMyScroll:nil];
    [self setMyPageCtrl:nil];
    [super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [splash0 release];
    [splash1 release];
    [splash2 release];
    [splash3 release];
    [splash4 release];
    
    [_myScroll release];
    [_myPageCtrl release];
    [super dealloc];
}
@end
