//
//  noteListCell.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface noteListCell : UITableViewCell

@property (nonatomic, retain) Note *note;
@property (weak, nonatomic) IBOutlet UILabel *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
