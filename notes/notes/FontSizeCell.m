//
//  FontSizeCell.m
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "FontSizeCell.h"

@implementation FontSizeCell

@synthesize myTextLabel,sizeLabel,slider;
@synthesize identificator;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

-(void)setupWithIdentificator:(NSString*)aIdentificator
{
    self.identificator = aIdentificator;
    
    [self.myTextLabel setText:NSLocalizedString(@"FontSizeCellLabel", nil)];
    
    float volume = [[NSUserDefaults standardUserDefaults] floatForKey:identificator];
    
    [self.sizeLabel setText:[NSString stringWithFormat:@"%i",(int)volume]];
    self.sizeLabel.font = [[self.sizeLabel font] fontWithSize:volume];
    
    [slider setValue:volume];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)sliderValueChanged:(UISlider *)sender
{
    float value = [sender value];
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:identificator];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.sizeLabel setText:[NSString stringWithFormat:@"%i",(int)value]];
    self.sizeLabel.font = [[self.sizeLabel font] fontWithSize:value];
    [delegate fontSizeCell:self didChangeFontSizeTo:(int)value];
}

@end
