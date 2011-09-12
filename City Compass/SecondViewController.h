//
//  SecondViewController.h
//  City Compass
//
//  Created by Fahd on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FRCurvedTextView.h"

@interface SecondViewController : UIViewController {
    FRCurvedTextView *firstCurvedLayer;
    IBOutlet FRCurvedTextView *secondCurvedLayer;
    IBOutlet FRCurvedTextView *thirdCurvedLayer;
    IBOutlet FRCurvedTextView *fourthCurvedLayer;
}

@property (nonatomic, retain) IBOutlet FRCurvedTextView *firstCurvedLayer;

@end
