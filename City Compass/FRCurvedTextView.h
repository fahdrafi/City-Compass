//
//  FRCurvedTextView.h
//  
//
//  Created by Fahd on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

@interface FRCurvedTextView : UIView {
    
    BOOL            setupRequired;

    CGFloat         _red;
    CGFloat         _green;
    CGFloat         _blue;
    CGFloat         _alpha;
    CTLineRef       _line;
    
    NSAttributedString* attString;
    NSMutableArray*     widthArray;
    NSMutableArray*     angleArray;
    
    CGFloat             textRadius;
    NSString*           text;
    UIColor*            textColor;
    NSString*           textFont;
    CGFloat             textSize;
    
}

@property (nonatomic, retain) NSString* textFont;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) NSString* text;
@property (nonatomic) CGFloat textRadius;
@property (nonatomic) CGFloat textSize;

@end

