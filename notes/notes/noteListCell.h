//
//  noteListCell.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface noteListCell : UITableViewCell <UITextFieldDelegate>
{
    BOOL swiped;
}

@property BOOL swiped;
@property (nonatomic, retain) Note *note;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *noteNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

-(void)setN:(Note*)newNote;
-(void)hidePasswordField;
-(void)showPasswordField;
-(void)swipeLockAt:(CGFloat)pixels;
-(void)alertShake;

@end