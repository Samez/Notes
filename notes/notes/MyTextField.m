//
//  MyTextField.m
//  notes
//
//  Created by Samez on 09.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
 [super drawRect:rect];
 [self setBackgroundColor:[UIColor whiteColor]];
 //Get the current drawing context
 
 CGContextRef context = UIGraphicsGetCurrentContext();
 //Set the line color and width
 CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor);
 CGContextSetLineWidth(context, 1.0f);
 //Start a new Path
 CGContextBeginPath(context);

 CGContextMoveToPoint(context, self.bounds.origin.x+5, self.font.leading + 1.5);
 CGContextAddLineToPoint(context, self.bounds.size.width-10, self.font.leading + 1.5);
 
 //Close our Path and Stroke (draw) it
 CGContextClosePath(context);
 CGContextStrokePath(context);
}

@end
