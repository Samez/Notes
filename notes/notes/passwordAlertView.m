//
//  passwordAlertView.m
//  notes
//
//  Created by Samez on 15.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "passwordAlertView.h"

@implementation passwordAlertView
@synthesize passwordIsAccepted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        passwordIsAccepted = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if ((buttonIndex == 1) && (!passwordIsAccepted))
            return;
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end
