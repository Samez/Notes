//
//  PreferencesViewController.h
//  notes
//
//  Created by Samez on 10.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellWithSwitcher.h"

@interface PreferencesViewController : UITableViewController<NSFetchedResultsControllerDelegate>
{
    BOOL simplyStyle;
    BOOL backgroundIsAdaptive;
}

@property (nonatomic, retain) NSFetchedResultsController *tabBarStyleFRC;
@property (nonatomic, retain) NSFetchedResultsController *backgroundFRC;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@property (strong, nonatomic) IBOutlet CellWithSwitcher *mySwitchCell;

@end
