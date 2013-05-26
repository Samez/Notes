//
//  testAddViewController.h
//  notes
//
//  Created by Samez on 02.04.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "MyTextView.h"
#import "MyTextField.h"

@interface testAddViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
{
    UIImageView *tempImageView;
    int nameSymbolCount;
    BOOL isPrivate;
    BOOL alertIsVisible;
    BOOL alerting;
    BOOL hidining;
    int orientation;
}
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet MyTextView *myTextView;
@property (weak, nonatomic) IBOutlet MyTextField *myNameField;

@property (weak, nonatomic) IBOutlet UILabel *timeText;

@property BOOL forEditing;
@property BOOL needFooterTitleForPrivateSection;
@property BOOL needFooterTitleForNameSection;

@property (nonatomic, retain) Note *note;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

- (IBAction)clickLockButton:(id)sender;
- (void)clickTrashButton:(id)sender;


@end
