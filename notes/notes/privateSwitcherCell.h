//
//  privateSwitcherCell.h
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface privateSwitcherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *stateSwitcher;
@property (nonatomic, retain) Note *note;

-(void)setNote:(Note *)newNote;

@end
