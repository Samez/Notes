//
//  testAddViewController.h
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "enterNameCell.h"
#import "enterTextCell.h"
#import "MyTextView.h"

@interface testAddViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate>
{
    UIImageView *tempImageView;
    int nameSymbolCount;
    BOOL isPrivate;
    BOOL alertIsVisible;
    BOOL alerting;
    BOOL hidining;
}

@property (weak, nonatomic) IBOutlet MyTextView *myTextView;
@property (weak, nonatomic) IBOutlet UITextField *myNameField;

@property (weak, nonatomic) IBOutlet UILabel *timeText;

@property BOOL forEditing;
@property BOOL needFooterTitleForPrivateSection;
@property BOOL needFooterTitleForNameSection;

@property (nonatomic, retain) Note *note;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *paperView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)clickLockButton:(id)sender;
- (void)clickTrashButton:(id)sender;


@end
