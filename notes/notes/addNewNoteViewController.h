//
//  addNewNoteViewController.h
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Pswd.h"
#import "privateSwitcherCell.h"
#import "enterNameCell.h"
#import "enterTextCell.h"



@interface addNewNoteViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate>
{
    BOOL needFooterTitle;
}

@property BOOL forEditing;
@property BOOL fromPass;
@property BOOL needFooterTitle;

@property (nonatomic, retain) Note *note;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
