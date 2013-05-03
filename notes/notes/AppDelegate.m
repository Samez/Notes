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

@synthesize tabBarController;
@synthesize notesListController;
@synthesize optionsController;
@synthesize window;

-(void) applicationDidFinishLaunching:(UIApplication *)application
{
    [self LoadSettings];

    [notesListController setManagedObjectContext:[self managedObjectContext]];
    
    [window setRootViewController:[self tabBarController]];
    
    [application setApplicationSupportsShakeToEdit:YES];
    
    [[LocalyticsSession shared] startSession:@"76ff7f96b13702a3e4d0fe0-ebd89cd8-b0f7-11e2-882a-005cf8cbabd8"];
    
    [[LocalyticsSession shared] setLoggingEnabled:YES];
    
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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"swipeColor"] == nil)
    {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor sashaGray]];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"swipeColor"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"needUpdateTime"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"needUpdateTime"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PasswordRequestInterval"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PasswordRequestInterval"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastTime"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"lastTime"];
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
