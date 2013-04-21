//
//  AppDelegate.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "AppDelegate.h"
#import "res.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize tabBarController;
@synthesize notesListController;
@synthesize optionsController;
@synthesize window;

-(void) applicationDidFinishLaunching:(UIApplication *)application
{
    [self LoadSettings];

    [notesListController setManagedObjectContext:[self managedObjectContext]];
    
    [window setRootViewController:[self tabBarController]];
    
    [[self window] makeKeyAndVisible];
}

- (void) LoadSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"simplyTabBarStyle"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"simplyTabBarStyle"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"secureTextEntry"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"secureTextEntry"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"password"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"pass" forKey:@"password"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"unsafeDeletion"];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Model10.2" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model10.2.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
