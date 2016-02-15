//
//  DataBaseManager.h
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseManager : NSObject

+(instancetype) sharedInstance;
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void)initializeDataBaseAndMapping;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
