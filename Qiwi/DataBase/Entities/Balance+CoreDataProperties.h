//
//  Balance+CoreDataProperties.h
//  Qiwi
//
//  Created by Admin on 15.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Balance.h"

NS_ASSUME_NONNULL_BEGIN

@interface Balance (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
