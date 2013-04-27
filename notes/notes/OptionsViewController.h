//
//  OptionsViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellWithSwitcher.h"
#import "TwoCaseCell.h"

@interface OptionsViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    BOOL simplyStyle;
    BOOL textEntryIsSecured;
    BOOL unsafeDeletion;
    BOOL swipeColorIsRed;
    BOOL needUpdateTime;
}

@property (strong, nonatomic) IBOutlet CellWithSwitcher *mySwitchCell;
@property (strong, nonatomic) IBOutlet TwoCaseCell *twoCaseCell;

@end
