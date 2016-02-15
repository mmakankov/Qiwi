//
//  User+CoreDataProperties.h
//  Qiwi
//
//  Created by Admin on 15.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *userId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Balance *> *balances;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addBalancesObject:(Balance *)value;
- (void)removeBalancesObject:(Balance *)value;
- (void)addBalances:(NSSet<Balance *> *)values;
- (void)removeBalances:(NSSet<Balance *> *)values;

@end

NS_ASSUME_NONNULL_END
