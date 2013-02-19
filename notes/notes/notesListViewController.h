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
#import "addNoteViewController.h"

@interface notesListViewController : UITableViewController <NSFetchedResultsControllerDelegate, NoteAddDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)showNote:(Note *)note animated:(BOOL)animated;
- (void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end