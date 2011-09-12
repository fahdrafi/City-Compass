//
//  FRCurvedTextView.m
//  
//
//  Created by Fahd on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRCurvedTextView.h"

#define kAngleSpread (M_PI/3.0)

@interface FRCurvedTextView ()
@property (readonly) NSAttributedString* attString;
@property (readonly) NSMutableArray* widthArray;
@property (readonly) NSMutableArray* angleArray;
@end

@implementation FRCurvedTextView

- (NSMutableArray*) angleArray {
    if (!angleArray) angleArray = [[NSMutableArray alloc] init];
    return angleArray;
}

- (NSMutableArray*) widthArray {
    if (!widthArray) widthArray = [[NSMutableArray alloc] init];
    return widthArray;
}

- (void)setupAttributedString {
    
//    UIFont* fontRef = [UIFont fontWithName:self.textFont size:self.textSize];
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)(self.textFont), self.textSize, NULL); //1

    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id)fontRef, kCTFontAttributeName, nil];
    
    CFRelease(fontRef);
    
    
    if (attString) [attString release];
    attString = [[NSAttributedString alloc] initWithString:self.text attributes:attrDictionary]; //2
    
}



- (UIColor*) textColor {
    if (!textColor) {
        self.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }
    return textColor;
}

- (void) setTextColor:(UIColor *)newColor {
    if (textColor) [textColor release];
    textColor = newColor;
    [textColor retain];

    const CGFloat*  _components = CGColorGetComponents([textColor CGColor]);
    _red = _components[0];
    _green = _components[1];
    _blue = _components[2];
    _alpha = _components[3];
    
    [self setNeedsDisplay];
}

- (void)dealloc {
    [attString release];
    [text release];
    [textColor release];
    [textFont release];
    [widthArray release];
    [angleArray release];
    CFRelease(_line);
    [super dealloc];
}

// Utility method to invert context
- (void)invertContext:(CGContextRef) context {
    CGContextSetTextMatrix(context, CGAffineTransformIdentity); //3
    CGContextTranslateCTM(context, self.bounds.size.width/2, self.bounds.size.height/2); //4
    CGContextScaleCTM(context, 1.0, -1.0); //5
    
}

- (void)setupDrawRectParameters {
    
    CGFloat         _lineLength;
    CGFloat         _textRadius;    
    CFIndex         _glyphCount;
    CFArrayRef      _runArray;
    CFIndex         _runCount;
    CTRunRef        _run;
    CFIndex         _runGlyphCount;
    NSNumber*       _widthValue;
    CFIndex         _glyphOffset = 0;
    CGFloat         _prevHalfWidth;
    NSNumber*       _angleValue;
    CGFloat         _halfWidth;
    CGFloat         _prevCenterToCenter;

    if (_line) CFRelease(_line);
    _line = CTLineCreateWithAttributedString((CFAttributedStringRef)(self.attString));//7
    _lineLength = CTLineGetTypographicBounds(_line, NULL, NULL, NULL);
    
    if (!_lineLength) return;
    
    _textRadius = self.textRadius;
    
    // Get the line, glyphs, runs
    _glyphCount = CTLineGetGlyphCount(_line); //8
    _runArray = CTLineGetGlyphRuns(_line);
    _runCount = CFArrayGetCount(_runArray); //9
    
    // Make array of width of all 
    _glyphOffset = 0;
    for (CFIndex i = 0; i < _runCount; i++) {
        _run = (CTRunRef)CFArrayGetValueAtIndex(_runArray, i);
        _runGlyphCount = CTRunGetGlyphCount((CTRunRef)_run);
        for (CFIndex j = 0; j < _runGlyphCount; j++) {
            
            _widthValue = [NSNumber numberWithDouble:CTRunGetTypographicBounds((CTRunRef)_run, CFRangeMake(j, 1), NULL, NULL, NULL)];
            [self.widthArray insertObject:_widthValue atIndex:(j + _glyphOffset)];  // 11
            
        }
        _glyphOffset = _runGlyphCount + 1;
        
    }
    
    // Store angles of glyphs in an array
    _prevHalfWidth =  [[self.widthArray objectAtIndex:0] floatValue] / 2.0;
    _angleValue = [NSNumber numberWithDouble:(_prevHalfWidth / _lineLength) * (_lineLength/_textRadius)]; // replace with angle if spread controlled
    [self.angleArray insertObject:_angleValue atIndex:0];
    for (CFIndex i = 1; i < _glyphCount; i++) {
        _halfWidth = [[self.widthArray objectAtIndex:i] floatValue] / 2.0;
        _prevCenterToCenter = _prevHalfWidth + _halfWidth;
        _angleValue = [NSNumber numberWithDouble:(_prevCenterToCenter / _lineLength) * (_lineLength/_textRadius)]; // replace with angle if spread controlled.
        [self.angleArray insertObject:_angleValue atIndex:i]; //13
        _prevHalfWidth = _halfWidth;
    }
    

}
//
//- (void) setAttString:(NSAttributedString *)newAttString {
//    if (!attString) [attString release];
//    attString = newAttString;
//    [attString retain];
//    [self setupDrawRectParameters];
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect]; //1
    
    CGFloat         _textRadius;    
    CFArrayRef      _runArray;
    CFIndex         _runCount;
    CGContextRef    _context;
    CGFloat         _lineLength;
    CFIndex         _glyphOffset;
    CTRunRef        _run;
    CFIndex         _runGlyphCount;
    CGPoint         _textPosition;
    CTFontRef       _runFont;
    CFRange         _glyphRange;
    CGFloat         _glyphWidth;
    CGFloat         _halfGlyphWidth;
    CGPoint         _positionForThisGlyph;
    CGGlyph         _glyph; 
    CGPoint         _position;
    CGAffineTransform _textMatrix;
    CGFontRef       _cgFont;
    NSMutableArray* _localWidthArray;
    NSMutableArray* _localAngleArray;
    
    if (setupRequired) {
        [self setupAttributedString];
        [self setupDrawRectParameters];
        setupRequired = NO;
    }
    
    _lineLength = CTLineGetTypographicBounds(_line, NULL, NULL, NULL);
    
    if (!_lineLength) return;

    _textRadius = self.textRadius;
    
    // Get the line, glyphs, runs
    _runArray = CTLineGetGlyphRuns(_line);
    _runCount = CFArrayGetCount(_runArray); //9
 
    // Inverting the reference frame to work with iOS
    _context = UIGraphicsGetCurrentContext(); //2
    [self invertContext:_context];
    
    // Rotate half way to the left so text aligns in the center!
    CGContextRotateCTM(_context, (_lineLength/2)/_textRadius); //6

    
    // Draw glyphs!
    _textPosition = CGPointMake(0.0, _textRadius);
    CGContextSetTextPosition(_context, _textPosition.x, _textPosition.y);
    _glyphOffset = 0;
    
    _localWidthArray = self.widthArray;
    _localAngleArray = self.angleArray;
    for (CFIndex i = 0; i < _runCount; i++) {
        _run = (CTRunRef)CFArrayGetValueAtIndex(_runArray, i);
        _runGlyphCount = CTRunGetGlyphCount(_run);
        _runFont = CFDictionaryGetValue(CTRunGetAttributes(_run), kCTFontAttributeName);
        for (CFIndex j = 0; j < _runGlyphCount; j++) {
             _glyphRange = CFRangeMake(j, 1);
            CGContextRotateCTM(_context, -[[_localAngleArray objectAtIndex:(j + _glyphOffset)] floatValue]); //14
            _glyphWidth = [[_localWidthArray objectAtIndex:(j + _glyphOffset)] floatValue];
            _halfGlyphWidth = _glyphWidth / 2.0;
            _positionForThisGlyph = CGPointMake(_textPosition.x - _halfGlyphWidth, _textPosition.y); //15
            _textPosition.x -= _glyphWidth;
            _textMatrix = CTRunGetTextMatrix(_run);
            _textMatrix.tx = _positionForThisGlyph.x; _textMatrix.ty = _positionForThisGlyph.y;
            CGContextSetTextMatrix(_context, _textMatrix);
            _cgFont = CTFontCopyGraphicsFont(_runFont, NULL);
            CTRunGetGlyphs(_run, _glyphRange, &_glyph);
            CTRunGetPositions(_run, _glyphRange, &_position);
            CGContextSetFont(_context, _cgFont);
            CGContextSetFontSize(_context, CTFontGetSize(_runFont));
            CGContextSetRGBFillColor(_context, _red, _green, _blue, _alpha);
            CGContextShowGlyphsAtPositions(_context, &_glyph, &_position, 1);
            CFRelease(_cgFont);
            
        }
        _glyphOffset += _runGlyphCount;
    }
    
}

- (void)setText:(NSString*) newText {
    if (!text) [text release];
    
    text = newText;
    [text retain];
    
    setupRequired = YES;
    [self setNeedsDisplay];
}

- (CGFloat) textRadius {
    if (!textRadius) {
        textRadius = 100.0;
        setupRequired = YES;
        [self setNeedsDisplay];
    }
    return textRadius;
}

- (void) setTextRadius:(CGFloat)newRadius {
    textRadius = newRadius;
    setupRequired = YES;
    [self setNeedsDisplay];
}

- (CGFloat) textSize {
    if (!textSize) {
        textSize = 14.0f;
        setupRequired = YES;
        [self setNeedsDisplay];
    }
    return textSize;
}

- (void) setTextSize:(CGFloat)newTextSize {
    textSize = newTextSize;
    setupRequired = YES;
    [self setNeedsDisplay];
}

- (NSString*) textFont {
    if (!textFont) {
        self.textFont = [NSString stringWithString:@"Arial Rounded MT Bold"];
        setupRequired = YES;
        [self setNeedsDisplay];
    }
    return textFont;
}

- (void) setTextFont:(NSString *)newFontName {
    if (textFont) [textFont release];
    textFont = newFontName;
    [textFont retain];
    setupRequired = YES;
    [self setNeedsDisplay];
}

- (NSAttributedString*) attString {
    if (!attString) {
        [self setupAttributedString];
        setupRequired = YES;
        [self setNeedsDisplay];

    }
    return attString;
}

- (NSString*) text {
    if (!text) {
        text = [[NSString alloc] initWithString:@""];
        setupRequired = YES;
        [self setNeedsDisplay];
    }
    return text;
}




@end
