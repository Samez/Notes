//
//  passwordViewController.h
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pswd.h"

@interface passwordViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    int rowsCount;
}

@property (nonatomic,retain) Pswd *pass;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
