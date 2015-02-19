//
//  ViewController.m
//  Movietest
//
//  Created by kubo naoko on 2013/08/19.
//  Copyright (c) 2013年 kubo naoko. All rights reserved.
//

#import "ViewController.h"
#import "MovieView.h"

@interface ViewController (){
    IBOutlet MovieView* movieView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)buttonClicked{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"fish02" ofType:@"mov"];
    NSURL *url = [NSURL fileURLWithPath:path];
   
    [movieView playMovie:url];
}
@end
