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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {

    }
    return self;
}
 
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setN:(Note *)newNote
{
    note = newNote;
    
    [self addSubview:img];
    
    if ([[note isPrivate] boolValue] == YES )
    {
        [img setImage:[UIImage imageNamed:@"lock.png"]];
    } else
    {
        [img setImage:nil];
    }

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
    
    NSString * timeString = [date_format stringFromDate: note.date];
    
    [timeLabel setText:timeString];
}


@end
