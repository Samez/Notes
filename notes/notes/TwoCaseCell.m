//
//  TwoCaseCell.m
//  notes
//
//  Created by Samez on 26.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "TwoCaseCell.h"
#import "res.h"

@implementation TwoCaseCell
@synthesize leftButton;
@synthesize rightButton;
@synthesize leftSelected;

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

- (IBAction)leftButtonClick:(id)sender
{
    
    [leftButton setSelected:YES];
    [rightButton setSelected:NO];
    [leftButton setBackgroundColor:[UIColor sashaGray]];
    [rightButton setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)rightButtonClick:(id)sender
{
    [leftButton setSelected:NO];
    [rightButton setSelected:YES];
    [rightButton setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    [leftButton setBackgroundColor:[UIColor whiteColor]];
}

@end
