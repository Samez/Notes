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

@interface notesListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSIndexPath *iP;
    NSString *PSWD;
    BOOL simpleTabBar;
    NSMutableArray *swipedCells;
    BOOL unsafeDeletion;
    BOOL canSwipe;
    BOOL canDelete;
    BOOL canTryToEnter;
    CustomAlertView *customAlertView;
    UIColor *swipeColor;
}

@property (strong, nonatomic) IBOutlet noteListCell *noteCell;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)showNote:(Note *)note animated:(BOOL)animated;
- (void)configureCell:(noteListCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)tryEnter;

@end
