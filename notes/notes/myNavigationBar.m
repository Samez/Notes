//
//  myNavigationBar.m
//  notes
//
//  Created by Samez on 06.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "myNavigationBar.h"

@implementation myNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
    return [super popNavigationItemAnimated:NO];
}

@end
