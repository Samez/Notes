//
//  detailViewController.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "detailViewController.h"

@interface detailViewController ()

@end

@implementation detailViewController

@synthesize note, nameLabel, textView, headerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(goToEditViewController:)];
    
    //self.navigationItem.rightBarButtonItem = editButtonItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    //[[NSBundle mainBundle] loadNibNamed:@"eventDetailViewController" owner:self options:nil];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
	self.navigationItem.title = @"Note";
    nameLabel.text = note.name;
    textView.text = note.text;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [self setTextView:nil];
    [self setNameLabel:nil];
    [super viewDidUnload];
}
@end
