//
//  privateSwitcherCell.m
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "CellWithSwitcher.h"

@implementation CellWithSwitcher

@synthesize stateSwitcher;
@synthesize myTextLabel;

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

@end
