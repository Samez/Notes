//
//  detailViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface detailViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) Note *note;

@end
