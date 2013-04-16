//
//  passwordViewController.h
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "passwordCell.h"

@interface passwordViewController : UITableViewController <UITextFieldDelegate>
{
    int rowsCount;
    NSString *bottomTitle;
    NSString *forOldPassword;
}

@property (nonatomic,retain) NSString *pass;

@property (strong, nonatomic) IBOutlet passwordCell *pswdCell;

@end
