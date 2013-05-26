//
//  OptionsViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellWithSwitcher.h"
#import "notesListViewController.h"

@interface OptionsViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    BOOL unsafeDeletion;
    BOOL swipeColorIsRed;
    NSMutableArray *intervalValueArray;
    NSMutableArray *intervalNameArray;
}

@property (strong, nonatomic) IBOutlet CellWithSwitcher *mySwitchCell;
@property notesListViewController *NLC;

@end
