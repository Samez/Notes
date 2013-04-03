//
//  testAddViewController.h
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Pswd.h"
#import "privateSwitcherCell.h"
#import "enterNameCell.h"
#import "enterTextCell.h"



@interface testAddViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate>
{
    UIImageView *tempImageView;
    int nameSymbolCount;
}
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UITextField *myNameField;


@property BOOL forEditing;
@property BOOL needFooterTitleForPrivateSection;
@property BOOL needFooterTitleForNameSection;

@property (nonatomic, retain) Note *note;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;


- (IBAction)clickLockButton:(id)sender;

@end
