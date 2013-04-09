//
//  noteListCell.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol OpenNote <NSObject>

-(void) openNote:(Note*) note;

@end

@interface noteListCell : UITableViewCell<UITextFieldDelegate>


@property (nonatomic, retain) Note *note;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *noteNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic)id<OpenNote> delegate;

-(void)setN:(Note*)newNote;
-(IBAction)tryOpen:(id)sender;
-(CGFloat)heightForTableView;

@end
