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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

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
    
    if (note.isPrivate == [NSNumber numberWithInt:1])
    {
        img.image=[UIImage imageNamed:@"lock.png"];
        [self addSubview:img];
    }
    
    self.textLabel.text = note.name;
    
}


@end
