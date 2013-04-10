//
//  notesListViewController.h
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "noteListCell.h"


@interface notesListViewController : UITableViewController <NSFetchedResultsControllerDelegate,OpenNote>
{
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) IBOutlet noteListCell *noteCell;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
