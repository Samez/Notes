//
//  Note.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "Note.h"


@implementation Note

@dynamic name;
@dynamic text;
@dynamic isPrivate;

-(void)setPrivate:(BOOL)priv
{
    if (priv)
        self.isPrivate = [NSNumber numberWithInt:1];
    else self.isPrivate = [NSNumber numberWithInt:0];
}

@end