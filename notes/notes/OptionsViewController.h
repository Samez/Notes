//
//  OptionsViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellWithSwitcher.h"

@interface OptionsViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    BOOL unsafeDeletion;
    BOOL swipeColorIsRed;
}

@property (strong, nonatomic) IBOutlet CellWithSwitcher *mySwitchCell;

@end
