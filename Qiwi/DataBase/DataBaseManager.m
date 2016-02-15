//
//  DataBaseManager.m
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import "DataBaseManager.h"
#import "Balance.h"
#import "User.h"

@implementation DataBaseManager

#pragma mark - Initialization

+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

-(instancetype) initUniqueInstance {
    return [super init];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)initializeDataBaseAndMapping {
    
    // Initialize managed object store
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithPersistentStoreCoordinator:[DataBaseManager sharedInstance].persistentStoreCoordinator];
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://w.qiwi.com"]];
    objectManager.managedObjectStore = managedObjectStore;
    
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    userMapping.identificationAttributes = @[ @"userId" ];
    [userMapping addAttributeMappingsFromDictionary:@{@"id": @"userId"}];
    [userMapping addAttributeMappingsFromArray:@[ @"name" ]];
    
    RKEntityMapping *balanceMapping = [RKEntityMapping mappingForEntityForName:@"Balance" inManagedObjectStore:managedObjectStore];
    balanceMapping.identificationAttributes = @[ @"currency"];
    [balanceMapping addAttributeMappingsFromArray:@[ @"currency", @"amount" ]];
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorCodeDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                             method:RKRequestMethodAny
                                                                                        pathPattern:nil
                                                                                            keyPath:@"result_code"
                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *errorMessageDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:nil
                                                                                               keyPath:@"message"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *usersResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodGET
                                                                                            pathPattern:@"/mobile/testtask/index.json"
                                                                                                keyPath:@"users"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *balancesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:balanceMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:@"/mobile/testtask/users/:userId/index.json"
                                                                                                   keyPath:@"balances"
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptorsFromArray:@[usersResponseDescriptor, balancesResponseDescriptor, errorCodeDescriptor, errorMessageDescriptor]];
    
    [objectManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"balances" objectClass:User.class pathPattern:@"/mobile/testtask/users/:userId/index.json" method:RKRequestMethodGET]];
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    _managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "QW.Qiwi" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Qiwi" withExtension:@"momd"];
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
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Qiwi.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext == nil) {
        [self initializeDataBaseAndMapping];
    }
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
