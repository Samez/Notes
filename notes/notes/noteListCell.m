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
@synthesize textField;
@synthesize imageView;

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

-(void) setNote:(Note *)newNote
{
    if(newNote!=note)
    {
        note = newNote;
    }
    
    textField.text = note.name;

    if (note.isPrivate)
    {
        UIImage *image = nil;
        image=[UIImage imageNamed:@"lock.png"];
        
        self.imageView.image = image;
    }
}

@end
