//
//  enterNameCell.h
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface enterNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (nonatomic, retain) Note *note;

-(void) setNote:(Note *)newNote;

-(NSString*)name;

@end
