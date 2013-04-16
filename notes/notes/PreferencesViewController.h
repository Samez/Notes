//
//  PreferencesViewController.h
//  notes
//
//  Created by Samez on 10.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellWithSwitcher.h"

@interface PreferencesViewController : UITableViewController
{
    BOOL simplyStyle;
    BOOL backgroundIsAdaptive;
    BOOL textEntryIsSecured;
    BOOL unsafeDeletion;
}

@property (strong, nonatomic) IBOutlet CellWithSwitcher *mySwitchCell;

@end
