//
//  addNewNoteViewController.m
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#define _NAME 1
#define _PRIVATE 0
#define _TEXT 2

#import "addNewNoteViewController.h"

@interface addNewNoteViewController ()

@end

@implementation addNewNoteViewController

@synthesize note;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize needFooterTitleForNameSection;
@synthesize needFooterTitleForPrivateSection;

@synthesize forEditing;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        forEditing = NO;
        needFooterTitleForPrivateSection = NO;
        needFooterTitleForNameSection = NO;
        tempImageView = [[UIImageView alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(forEditing)
        self.navigationItem.title = @"Edit note";
    else
        self.navigationItem.title = @"Add note";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.tableView.allowsSelection = NO;

}

- (void)save
{
    
    if ([self saveName])
    {
        [self saveText];
        
        [self saveState];
        
        if(!forEditing)
            [note setDate:[NSDate date]];
        
        NSError *error = nil;
        
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } else
    {
        needFooterTitleForNameSection = YES;
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: 1] withRowAnimation: UITableViewRowAnimationNone];

    }
}

- (void)cancel
{
	if (!forEditing)
        [self.managedObjectContext deleteObject:note];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)saveState
{
    privateSwitcherCell *getStateCell = (privateSwitcherCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_PRIVATE]];
    [note setIsPrivate:[NSNumber numberWithBool:[getStateCell.stateSwitcher isOn]]];
}

-(BOOL)saveName
{
    enterNameCell * getNameCell = (enterNameCell *)[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:_NAME]];
    
    if ([[[getNameCell nameField] text] length]!=0)
    {
        [note setName:[[getNameCell nameField] text]];
        return YES;
    }
    return NO;
}

-(void)saveText
{
    enterTextCell *getTextCell = (enterTextCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_TEXT]];
    
    [note setText:[[getTextCell textFieldView] text]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] == _NAME)
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView tag] == _TEXT)
    {
        if([text isEqualToString:@"\n"])
        {
            [textView resignFirstResponder];
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case _NAME:
            title = @"Name";
            break;
        case _PRIVATE:
            //title = @"";
            break;
        case _TEXT:
            title = @"Text";
            break;
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=0.0f;
    
    switch (indexPath.section)
    {
        case _PRIVATE:
            height = 44.0;
            break;
        case _TEXT:
            height = 132.0;
            break;
        case _NAME:
            height = 44.0;
            break;
    }
    return height;
    
}

-(void)stateWasChanged:(id)sender
{
    privateSwitcherCell *cell = (privateSwitcherCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_PRIVATE]];
    
    [self setNeedFooterTitleForPrivateSection:[cell.stateSwitcher isOn]];
    
    [self saveState];
    
    [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: _PRIVATE] withRowAnimation: UITableViewRowAnimationNone];

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case _PRIVATE:
            if ([self needFooterTitleForPrivateSection])
            {
                if ([((Pswd*)fetchedResultsController.fetchedObjects[0]).password isEqualToString:@"Password"])
                    title = @"The record will be protected by default password - 'Password'. To change the password, go to options.";
                else
                    title = @"The record will be protected by your password";
            }
            break;
        case _NAME:
            if(needFooterTitleForNameSection)
                title = @"You must enter the name of the note";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    
    
    switch (indexPath.section)
    {
        case _PRIVATE:
        {
            static NSString *CellIdentifier = @"privateSwitcher";
            
            privateSwitcherCell *MYcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (MYcell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"privateSwitcher" owner:self options:nil];
                MYcell = [topLevelObjects objectAtIndex:0];
            }
            
            //if (note.isPrivate!=nil)
                [MYcell.stateSwitcher setOn:[note.isPrivate boolValue]];

            [MYcell.stateSwitcher addTarget: self action: @selector(stateWasChanged:) forControlEvents:UIControlEventValueChanged];
            
            return MYcell;
            break;
        }
        case _NAME:
        {
            static NSString *CellIdentifier = @"enterNameCell";
            enterNameCell *MYcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (MYcell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"enterNameCell" owner:self options:nil];
                MYcell = [topLevelObjects objectAtIndex:0];
            }
            
            [MYcell setNote:note];
            
            MYcell.nameField.delegate = self;
            MYcell.nameField.tag = _NAME;
            MYcell.nameField.returnKeyType = UIReturnKeyDone;
            
            return MYcell;
        }
        case _TEXT:
        {
            static NSString *CellIdentifier = @"enterTextCell";
            enterTextCell *MYcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (MYcell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"enterTextCell" owner:self options:nil];
                MYcell = [topLevelObjects objectAtIndex:0];
            }
            
            [MYcell setNote:note];
            
            MYcell.textFieldView.delegate = self;
            MYcell.textFieldView.tag = _TEXT;
            MYcell.textFieldView.returnKeyType = UIReturnKeyDone;
            
            return MYcell;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pswd" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"password" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
    }
	
	return fetchedResultsController;
}

@end
