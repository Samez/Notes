//
//  addNewNoteViewController.m
//  notes
//
//  Created by Samez on 20.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "addNewNoteViewController.h"

@interface addNewNoteViewController ()

@end

@implementation addNewNoteViewController

@synthesize note;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add note";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)save
{
    
	NSError *error = nil;
	if (![note.managedObjectContext save:&error])
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    //[self.delegate NoteAddViewController:self didAddNote:note];
}

- (void)cancel
{
	
	[note.managedObjectContext deleteObject:note];
    
	NSError *error = nil;
	if (![note.managedObjectContext save:&error]) {
        
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    //[self.delegate NoteAddViewController:self didAddNote:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    /*
    switch (indexPath.section)
    {
        case 0:
        {
            //static NSString *CellIdentifier = @"privateSwitcherCell";
            //privateSwitcherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            privateSwitcherCell *cell = [[privateSwitcherCell alloc] init];
            return cell;
        }
        case 1:
        {
            //static NSString *CellIdentifier = @"enterNameCell";
            //enterNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            enterNameCell *cell = [[enterNameCell alloc] init];
            return cell;
        }
        case 2:
        {
            //static NSString *CellIdentifier = @"enterTextCell";
            //enterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            enterTextCell *cell = [[enterTextCell alloc] init];
            return cell;
        }
    }
    */
    return [[UITableViewCell alloc] init];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
