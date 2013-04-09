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
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

-(void)hideImg
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [img setAlpha:0];
    [UIView commitAnimations];
}

-(void)showImg
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [img setAlpha:1];
    [UIView commitAnimations];
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if(editing)
    {
        [self hideImg];
    } else [self showImg];
}

-(void)setN:(Note *)newNote
{
    note = newNote;
    
    [self addSubview:img];
    
    if ([note.isPrivate boolValue] == YES )
    {
        img.image=[UIImage imageNamed:@"lock.png"];
    } else
    {
        img.image = nil;
    }

    UIFont *mainFont = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [noteNameLabel setFont:mainFont];
    
    noteNameLabel.text = note.name;
    
    NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
    [date_format setDateFormat: @"HH:mm MMMM d, YYYY"];
    NSString * timeString = [date_format stringFromDate: note.date];
    
    timeLabel.text = timeString;
}

-(CGFloat)heightForTableView
{
    if (note.isPrivate)
    {
        return 90.0;
    }else return 50.0;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self tryOpen:nil];
    return YES;
}

-(IBAction)tryOpen:(id)sender
{
    if (note.isPrivate)
    {
        [self.passwordField becomeFirstResponder];
        if (![self.passwordField.text isEqual:@"1234"]) return;
        self.passwordField.text=@"";
    }
    [self.passwordField resignFirstResponder];
    [delegate openNote:self.note];
}

@end
