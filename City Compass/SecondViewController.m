//
//  SecondViewController.m
//  City Compass
//
//  Created by Fahd on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"

#import "FRCurvedTextView.h"

@implementation SecondViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((FRCurvedTextView*)self.view).text = @"This application gives you the bearing to any destination in the world! Written by Fahd Rafi";
    ((FRCurvedTextView*)self.view).textRadius = 130.0;
    ((FRCurvedTextView*)self.view).textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
