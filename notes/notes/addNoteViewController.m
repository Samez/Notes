//
//  addNoteViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "addNoteViewController.h"

@interface addNoteViewController ()

@end

@implementation addNoteViewController

@synthesize nameField,textField;
@synthesize note;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Add note";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	
	[nameField becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save {
    
    note.name = nameField.text;
    
    note.text = textField.text;
    
	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
        
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    [self.delegate NoteAddViewController:self didAddNote:note];
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
	if (_textField == nameField) {
		[nameField resignFirstResponder];
		[self save];
	}
	return YES;
}

- (void)cancel {
	
	[note.managedObjectContext deleteObject:note];
    
	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
        
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    [self.delegate NoteAddViewController:self didAddNote:nil];
}

@end
