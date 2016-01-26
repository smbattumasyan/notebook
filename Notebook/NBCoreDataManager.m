//
//  NBCoreDataManager.m
//  Notebook
//
//  Created by Smbat Tumasyan on 12/23/15.
//  Copyright © 2015 EGS. All rights reserved.
//

#import "NBCoreDataManager.h"

@implementation NBCoreDataManager

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController   = _fetchedResultsController;

//------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------------------

+ (nonnull instancetype)sharedManager {
    
    static NBCoreDataManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
    sharedInstance = [[NBCoreDataManager alloc] init];
    });
    
    return sharedInstance;
}

//------------------------------------------------------------------------------------------
#pragma mark - Data Managers
//------------------------------------------------------------------------------------------

- (BOOL)saveObject{
    
    NSError *error = nil;
    BOOL status    = [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"addList error: %@", error);
    }
    
    return status;
}

- (void)deleteNote:(Note *)managedObject {
    
    [self.managedObjectContext deleteObject:managedObject];
    [self saveObject];
}

- (Note *)addNote:( nullable NSDictionary *)details {
    
    Note *aNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                               inManagedObjectContext:self.managedObjectContext];
    aNote.name = details[@"name"];
    aNote.details = details[@"details"];
    aNote.date = details[@"date"];
    aNote.folder = details[@"folder"];
    [self saveContext];
    
    return aNote;
}

- (void)deleteFolder:(Folder *)managedObject {
    
    [self.managedObjectContext deleteObject:managedObject];
    [self saveObject];
}

- (nullable Folder *)addFolder:(nullable NSDictionary *)details
{
    Folder *aFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:self.managedObjectContext];
    aFolder.name    = details[@"name"];
    aFolder.date    = [NSDate date];
    
    [self saveContext];
    
    return aFolder;
}
//-------------------------------------------------------------------------------------------
#pragma mark - Core Data Stack
//-------------------------------------------------------------------------------------------

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.EGS.Notebook" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL     = [[NSBundle mainBundle] URLForResource:@"Notebook" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL             = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Notebook.sqlite"];
    NSLog(@"storeURL %@", storeURL);
    NSError *error              = nil;
    NSString *failureReason     = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict              = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey]        = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey]             = error;
        error                                  = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext                     = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Fetch Result Controller
//-------------------------------------------------------------------------------------------

- (nullable NSFetchedResultsController *)fetchedResultsController:(FetchRequestEntityType)entity {
    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:[self setFetchRequestForEntity:entity]
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil cacheName:@"local"];
    NSError *error = nil;
   
    if( ! [fetch performFetch: &error] ) {
        NSLog( @"Error Description: %@", [error userInfo] );
    }
    return fetch;
}

- (nullable NSFetchedResultsController *)fetchedResultsControllerFor: (Folder *)folder searchBar:(NSString *)searchBar {
    
    NSFetchRequest *request          = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    NSPredicate *predicate           = [NSPredicate predicateWithFormat:@"folder == %@", folder];
    if ([searchBar length] > 0) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchBar];
        [request setPredicate:pred];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"date" ascending: NO];

    [request setPredicate:predicate];
    [request setSortDescriptors: @[sortDescriptor]];

    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if( ! [fetch performFetch: &error] ) {
        NSLog( @"Error Description: %@", [error userInfo] );
    }
    return fetch;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private Methods
//-------------------------------------------------------------------------------------------
-(NSFetchRequest *)setFetchRequestForEntity:(FetchRequestEntityType)entity
{
    NSSortDescriptor *sortDescriptor;
    NSFetchRequest   *request;
    
    switch (entity) {
        case FetchRequestEntityTypeNote:{
            request        = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: NO];
            break;
        }
        case FetchRequestEntityTypeFolder:{
            request        = [NSFetchRequest fetchRequestWithEntityName:@"Folder"];
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"date" ascending: NO];
            break;
        }
            break;
        default:
            break;
    }
    [request setSortDescriptors: @[sortDescriptor]];
    
    return request;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Core Data Saving support
//-------------------------------------------------------------------------------------------

- (void)saveContext
{
    NSError *error                               = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
