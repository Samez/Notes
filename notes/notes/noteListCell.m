//
//  noteListCell.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "noteListCell.h"

@implementation noteListCell

@synthesize note;
@synthesize img;
@synthesize timeLabel;
@synthesize noteNameLabel;
@synthesize passwordField;
@synthesize alert;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [passwordField setDelegate:self];
        alert = NO;
    }
    return self;
}

-(void)swipeCellAt:(CGFloat)xPixels
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                             [img setFrame:CGRectMake(img.frame.origin.x - xPixels, img.frame.origin.y, img.frame.size.width, img.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)setAlertImage
{
    if (alert)
        [self setNormalImage];
    
    [passwordField becomeFirstResponder];
    
    [passwordField setText:nil];
    
    [img setAlpha:0];
    [img setImage:[UIImage imageNamed:@"alert.png"]];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [img setAlpha:1];
                     }
                     completion:^(BOOL finished){
                         alert = YES;
                     }];
}

-(void)setNormalImage
{
    [img setImage:[UIImage imageNamed:@"lock.png"]];
    
    alert = NO;
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

}

@end
