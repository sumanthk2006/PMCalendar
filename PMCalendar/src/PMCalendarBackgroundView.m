//
//  PMCalendarBackgroundView.m
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMCalendarBackgroundView.h"
#import "PMCalendarConstants.h"
#import "PMCalendarHelpers.h"
#import "PMTheme.h"

UIEdgeInsets shadowPadding = kPMThemeShadowInsets;
CGFloat cornerRadius = kPMThemeCornerRadius;
CGFloat headerHeight = kPMThemeHeaderHeight;
CGSize innerPadding = kPMThemeInnerPadding;

@interface PMCalendarBackgroundView ()

- (void)redrawComponent;

@end

@implementation PMCalendarBackgroundView

@synthesize arrowDirection = _arrowDirection;
@synthesize arrowPosition = _arrowPosition;

#pragma mark - UIView overridden methods -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) 
    {
        return nil;
    }    
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawComponent)
                                                 name:kPMCalendarRedrawNotification
                                               object:nil];
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

#pragma mark - component drawing management -

- (void)redrawComponent
{
    [self setNeedsDisplay];
}

// Returns background bezier path with arrow pointing to a given 
// arrowDirection and arrowPosition (top corner of a triangle).
+ (UIBezierPath*) createBezierPathForSize:(CGSize) size
                           arrowDirection:(PMCalendarArrowDirection)direction 
                            arrowPosition:(CGPoint)arrowPosition
{
    UIBezierPath* result = nil;
    CGFloat width = size.width;
    CGFloat height = size.height;
    width -= shadowPadding.left + shadowPadding.right;
    height -= shadowPadding.top + shadowPadding.bottom;

    if (arrowSize.height == 0)
    {
        CGRect pathRect = CGRectMake(shadowPadding.top
                                     , shadowPadding.left
                                     , width
                                     , height);
        
        if (cornerRadius > 0)
        {
            result = [UIBezierPath bezierPathWithRoundedRect:pathRect
                                                cornerRadius:cornerRadius];
        }
        else
        {
            result = [UIBezierPath bezierPathWithRect:pathRect];
        }
        
        return result;
    }
    
    result = [UIBezierPath bezierPath];
    CGPoint startArrowPoint = CGPointZero;
    CGPoint endArrowPoint = CGPointZero;
    CGPoint topArrowPoint = CGPointZero;
    CGPoint offset = CGPointMake(shadowPadding.top, shadowPadding.left);
    CGPoint tl = CGPointZero;

    switch (direction) 
    {
        case PMCalendarArrowDirectionUp: // going from right side to the left
                                         // so start point is a bottom RIGHT point of a triangle ^. this one :)
            startArrowPoint = CGPointMake(arrowSize.width / 2, arrowSize.height);
            endArrowPoint = CGPointMake(-arrowSize.width / 2, arrowSize.height);
            offset = CGPointOffset(offset, arrowPosition.x, 0);
            tl.y = arrowSize.height;
            break;
        case PMCalendarArrowDirectionDown: // going from left to right
                                           // so start point is a top LEFT point of a triangle - 'V
            startArrowPoint = CGPointMake(-arrowSize.width / 2, -arrowSize.height);
            endArrowPoint = CGPointMake(arrowSize.width / 2, -arrowSize.height);
            offset = CGPointOffset(offset, arrowPosition.x, height + arrowSize.height);
            break;
        case PMCalendarArrowDirectionLeft: // going from top to bottom
                                            // so start point is a top RIGHT point of a triangle - <'
            startArrowPoint = CGPointMake(arrowSize.height, -arrowSize.width / 2);
            endArrowPoint = CGPointMake(arrowSize.height, arrowSize.width / 2);
            offset = CGPointOffset(offset, 0, arrowPosition.y);
            tl.x = arrowSize.height;
            break;
        case PMCalendarArrowDirectionRight: // going from bottom to top
                                            // so start point is a bottom RIGHT point of a triangle - .>
            startArrowPoint = CGPointMake(-arrowSize.height, arrowSize.width / 2);
            endArrowPoint = CGPointMake(-arrowSize.height, -arrowSize.width / 2);
            offset = CGPointOffset(offset, width + arrowSize.height, arrowPosition.y);
            break;
            
        default:
            break;
    }
    
    startArrowPoint = CGPointOffsetByPoint(startArrowPoint, offset);
    endArrowPoint = CGPointOffsetByPoint(endArrowPoint, offset);
    topArrowPoint = CGPointOffsetByPoint(topArrowPoint, offset);
        
    void (^createBezierArrow)(void) = ^{
        [result addLineToPoint: startArrowPoint];
        [result addLineToPoint: topArrowPoint];
        [result addLineToPoint: endArrowPoint];
    };
    
    // starting from bottom-left corner
    [result moveToPoint: CGPointMake(tl.x + shadowPadding.left
                                     , tl.y + shadowPadding.top + height - cornerRadius)];
    // creating arc to a bottom line
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                         , tl.y + shadowPadding.top + height - cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(180) 
                    endAngle:radians(90)
                   clockwise:NO];
    // checking if we have an arrow on a bottom of the background
    if (direction == PMCalendarArrowDirectionDown)
    {
        // draw it if yes
        createBezierArrow();
    }
    // same steps for bottom-right corner
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                        , tl.y + shadowPadding.top + height)];
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                         , tl.y + shadowPadding.top + height - cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(90) 
                    endAngle:radians(0)
                   clockwise:NO];
    if (direction == PMCalendarArrowDirectionRight)
    {
        createBezierArrow();
    }
    // same steps for top-right corner
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left + width
                                        , tl.y + shadowPadding.top + cornerRadius)];
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                         , tl.y + shadowPadding.top + cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(0) 
                    endAngle:radians(-90)
                   clockwise:NO];
    if (direction == PMCalendarArrowDirectionUp)
    {
        createBezierArrow();
    }
    // same steps for top-left corner
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                        , tl.y + shadowPadding.top)];
    [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                         , tl.y + shadowPadding.top + cornerRadius) 
                      radius:cornerRadius 
                  startAngle:radians(-90) 
                    endAngle:radians(-180)
                   clockwise:NO];
    if (direction == PMCalendarArrowDirectionLeft)
    {
        createBezierArrow();
    }    
    // return back to the starting point
    [result addLineToPoint: CGPointMake(tl.x + shadowPadding.left
                                        , tl.y + shadowPadding.top + height - cornerRadius)];

    [result closePath];
    
    return result;
};

-(void)drawRect:(CGRect)rect
{
    PMLog( @"Start" );
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    // color declarations
    UIColor* bigBoxInnerShadowColor = kPMThemeBackgroundInnerShadowColor;
    UIColor* backgroundLightColor = kPMThemeBackgroundColor;
    UIColor* lineLightColor = kPMThemeSeparatorColor;
    UIColor* boxStroke = kPMThemeBoxStrokeColor;

    // overlay gradient colors
    NSArray* gradient2Colors = kPMThemeBackgoundOverlayGradientColors;
    CGFloat gradient2Locations[] = kPMThemeBackgoundOverlayGradientColorLocations;
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace
                                                         , (__bridge CFArrayRef)gradient2Colors
                                                         , gradient2Locations);

    // shadow declarations
    CGColorRef bigBoxInnerShadow = bigBoxInnerShadowColor.CGColor;
    CGSize bigBoxInnerShadowOffset = CGSizeMake(0, 1);
    CGFloat bigBoxInnerShadowBlurRadius = 1;
    CGColorRef backgroundShadow = [UIColor blackColor].CGColor;
    CGSize backgroundShadowOffset = CGSizeMake(1, 1);
    CGFloat backgroundShadowBlurRadius = shadowPadding.bottom;
    CGColorRef shadow = kPMThemeSeparatorShadowColor.CGColor;
    UIOffset shadowOffset = kPMThemeSeparatorShadowOffset;
    CGFloat shadowBlurRadius = 0;

    // backgound box. it doesn't include arrow:
    CGRect boxBounds = CGRectMake(0, 0
                                  , self.bounds.size.width - arrowSize.height
                                  , self.bounds.size.height - arrowSize.height);

    CGFloat width = boxBounds.size.width - (shadowPadding.left + shadowPadding.right);
    CGFloat height = boxBounds.size.height - (shadowPadding.top + shadowPadding.bottom);

    CGPoint tl = CGPointZero;

    switch (self.arrowDirection) 
    {
        case PMCalendarArrowDirectionUp:
            tl.y = arrowSize.height;
            boxBounds.origin.y = arrowSize.height;
            break;
        case PMCalendarArrowDirectionLeft:
            tl.x = arrowSize.height;
            boxBounds.origin.x = arrowSize.height;
            break;
        default:
            break;
    }

    // draws background of popover
    UIBezierPath *roundedRectanglePath = [PMCalendarBackgroundView createBezierPathForSize:boxBounds.size
                                                                            arrowDirection:self.arrowDirection
                                                                             arrowPosition:self.arrowPosition];

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, backgroundShadowOffset, backgroundShadowBlurRadius, backgroundShadow);

    // light stroke around
    if (boxStroke)
    {
        [boxStroke setStroke];
        roundedRectanglePath.lineWidth = 0.5;
        [roundedRectanglePath stroke];
    }
    [backgroundLightColor setFill];
    [roundedRectanglePath fill];

    // background inner shadow
    CGRect roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds]
                                                    , -bigBoxInnerShadowBlurRadius
                                                    , -bigBoxInnerShadowBlurRadius);
    roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect
                                              , -bigBoxInnerShadowOffset.width
                                              , -bigBoxInnerShadowOffset.height);
    roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect
                                                         , [roundedRectanglePath bounds]), -1, -1);
    
    UIBezierPath* roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangleBorderRect];
    [roundedRectangleNegativePath appendPath: roundedRectanglePath];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;

    CGContextSaveGState(context);
    {
        CGFloat xOffset = bigBoxInnerShadowOffset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = bigBoxInnerShadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset)
                                               , yOffset + copysign(0.1, yOffset)),
                                    bigBoxInnerShadowBlurRadius,
                                    bigBoxInnerShadow);
        
        [roundedRectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width)
                                                                       , 0);
        [roundedRectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [roundedRectangleNegativePath fill];
    }
    CGContextRestoreGState(context);

    UIBezierPath *roundedRectangle2Path = [PMCalendarBackgroundView createBezierPathForSize:boxBounds.size
                                                                            arrowDirection:self.arrowDirection
                                                                             arrowPosition:self.arrowPosition];
    
    CGContextSaveGState(context);
    [roundedRectangle2Path addClip];
    CGContextRestoreGState(context);

    if (kPMThemeSeparatorWidth > 0)
    {
        // dividers        
        CGFloat hDiff = (width + shadowPadding.left + shadowPadding.right - innerPadding.width * 2) / 7;
        
        for (int i = 0; i < 6; i++) 
        {
            CGRect dividerRect = CGRectMake(tl.x + innerPadding.width + floor((i + 1) * hDiff) - 1 + shadowPadding.left
                                            , tl.y + innerPadding.height + headerHeight + shadowPadding.top
                                            , kPMThemeSeparatorWidth
                                            , height - innerPadding.height * 2 - headerHeight);
            UIBezierPath* dividerPath = [UIBezierPath bezierPathWithRect:dividerRect];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, UIOffsetToCGSize(shadowOffset), shadowBlurRadius, shadow);
            [lineLightColor setFill];
            [dividerPath fill];
            CGContextRestoreGState(context);
        }
    }

    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context
                                , gradient2
                                , CGPointMake(width / 2, shadowPadding.top + self.frame.size.height)
                                , CGPointMake(width / 2, shadowPadding.top), 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient2);
    
    CGColorSpaceRelease(colorSpace);
    PMLog( @"End" );
}

- (void)setFrame:(CGRect)frame
{
    BOOL needsRedraw = NO;
    
    if (!CGSizeEqualToSize(self.frame.size, frame.size))
    {
        needsRedraw = YES;
    }
    
    [super setFrame:frame];
    
    if (needsRedraw)
    {
        [self redrawComponent];
    }
}

@end

