//
//  FontCell.m
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "FontCell.h"

@implementation FontCell

@synthesize myDetailLabel,myTextLabel;
@synthesize myIdentificator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myIdentificator = [[NSString alloc] init];
    }
    return self;
}

-(void)setupWithIdentificator:(NSString *)identificator
{
    myIdentificator = [NSString stringWithString:identificator];
    
    NSMutableString *forTitle = [NSMutableString stringWithString:identificator];
    [forTitle appendString:@"CellLabel"];

    [self.myTextLabel setText:NSLocalizedString(forTitle, nil)];
    
    NSString *font = [[NSUserDefaults standardUserDefaults] stringForKey:identificator];
    
    NSMutableString *key = [NSMutableString stringWithString:identificator];
    [key appendString:@"Size"];
    
    [[self myDetailLabel] setText:font];
    [[self myDetailLabel] setFont:[UIFont fontWithName:font size:[[NSUserDefaults standardUserDefaults] integerForKey:key]]];
}

@end
