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
    NSString*           fontName;
    
}

@property (nonatomic, retain) NSString* fontName;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) NSString* text;
@property (nonatomic) CGFloat textRadius;

@end

