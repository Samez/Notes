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
#import "CustomAlertView.h"
#import "addNewNoteViewController.h"
#import "SearchView.h"
#import "SearchField.h"

@interface notesListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, SearchViewDelegate>
{
    NSIndexPath *iP;
    NSString *PSWD;
    NSMutableArray *swipedCells;
    BOOL unsafeDeletion;
    BOOL canSwipe;
    BOOL canDelete;
    BOOL canTryToEnter;
    CustomAlertView *customAlertView;
    UIColor *swipeColor;
    BOOL returnedFromOptions;
    int orientation;
    SearchView *searchView;
    NSString *myPredicate;
    BOOL searchingNow;
}

@property (strong, nonatomic) IBOutlet noteListCell *noteCell;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)showNoteAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
- (void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)tryEnter;

@end

