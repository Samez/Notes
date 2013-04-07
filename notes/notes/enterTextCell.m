//
//  enterTextCell.m
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "enterTextCell.h"

@implementation enterTextCell

@synthesize note;
@synthesize textFieldView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNote:(Note *)newNote
{
    note = newNote;
    
    if ([note text])
    {
        [textFieldView setText:[note text]];
    }
}

-(NSString*) NoteText
{
    return [note name];
}

@end
