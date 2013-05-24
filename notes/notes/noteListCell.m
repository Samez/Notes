//
//  noteListCell.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "noteListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "res.h"

@implementation noteListCell

@synthesize note;
@synthesize img;
@synthesize timeLabel;
@synthesize noteNameLabel;
@synthesize passwordField;
@synthesize swiped;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [passwordField setDelegate:self];
        swiped= NO;
        swiped = NO;
    }
    return self;
}

-(void)alertShake
{
    [passwordField becomeFirstResponder];
    [passwordField setText:nil];
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(img.center.x - 5,img.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(img.center.x + 5, img.center.y)]];
    [img.layer addAnimation:shake forKey:@"position"];
}

-(void)hidePasswordField
{
    [passwordField resignFirstResponder];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [passwordField setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)showPasswordField
{
    [passwordField setText:nil];
    [passwordField becomeFirstResponder];
    
    [UIView animateWithDuration:0.6
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [passwordField setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)setN:(Note *)newNote
{
    note = newNote;
    
    [self addSubview:img];
    
    if ([[note isPrivate] boolValue] == YES )
        [img setImage:[UIImage imageNamed:@"lock.png"]];
    else
        [img setImage:nil];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    UIFont *mainFont = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    
    [noteNameLabel setFont:mainFont];
    
    if ([note name]!=nil)
        [noteNameLabel setText:[note name]];
    else
    {
         if ([[note text] length] > 25)
             [noteNameLabel setText:[[note text] substringToIndex:25]];
         else
             [noteNameLabel setText:[note text]];
    }
    
    NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
    
    [date_format setDateFormat: @"HH:mm MMMM d, YYYY"];
    
    NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
    
    [date_format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:identifier]];
    
    NSString * timeString = [date_format stringFromDate: note.date];
    
    [timeLabel setText:timeString];

    [noteNameLabel setFont:[UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"] size:17]];
}

@end
