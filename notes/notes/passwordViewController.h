//
//  passwordViewController.h
//  notes
//
//  Created by Samez on 26.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pswd.h"
#import "passwordCell.h"

@interface passwordViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>
{
    int rowsCount;
    NSString *bottomTitle;
    NSString *forOldPassword;
}

@property (nonatomic,retain) Pswd *pass;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet passwordCell *pswdCell;

@end
