//
//  AppDelegate.m
//  notes
//
//  Created by Samez on 19.02.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "AppDelegate.h"
#import "res.h"
#import "LocalyticsSession.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize notesListController;
@synthesize window;
@synthesize notesNavController;

-(void) applicationDidFinishLaunching:(UIApplication *)application
{
    [self LoadSettings];

    [notesListController setManagedObjectContext:[self managedObjectContext]];
    
    [window setRootViewController:notesNavController];
    
    [application setApplicationSupportsShakeToEdit:YES];
    
    [[LocalyticsSession shared] startSession:@"76ff7f96b13702a3e4d0fe0-ebd89cd8-b0f7-11e2-882a-005cf8cbabd8"];
    
    [[LocalyticsSession shared] setLoggingEnabled:NO];
    
    [[self window] makeKeyAndVisible];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:1] forKey:@"lastTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) LoadSettings
{    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"password"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"pass" forKey:@"password"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unsafeDeletion"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"unsafeDeletion"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"swipeColor"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PasswordRequestInterval"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PasswordRequestInterval"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastTime"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:0]forKey:@"lastTime"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PasswordRequestInterval"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PasswordRequestInterval"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFontSize"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:18.0 forKey:@"noteNameFontSize"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteTextFontSize"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:14.0 forKey:@"noteTextFontSize"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteNameFont"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:@"noteNameFont"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noteTextFont"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:@"noteTextFont"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"selectedItemColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectedItemColor"];
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unselectedItemColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"unselectedItemColor"];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:1] forKey:@"lastTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
