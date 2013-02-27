//
//  askPasswordViewController.h
//  notes
//
//  Created by Samez on 27.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Pswd.h"
#import "passwordViewController.h"

@interface askPasswordViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>
{
    passwordViewController *passViewController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,retain) Note *note;
@property (nonatomic,retain) Pswd *pass;

@end
