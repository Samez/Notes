//
//  FontTableViewController.h
//  notes
//
//  Created by Samez on 24.05.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontSizeCell.h"
#import "FontCell.h"

@interface FontTableViewController : UITableViewController <FontSizeCellDelegate>

@property (strong, nonatomic) IBOutlet FontSizeCell *fontSizeCell;

@property (strong, nonatomic) IBOutlet FontCell *fontCell;

@end
