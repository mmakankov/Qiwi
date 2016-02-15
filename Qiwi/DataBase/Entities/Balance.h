//
//  Balance.h
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Balance : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (NSString *)localizedValue;

@end

NS_ASSUME_NONNULL_END

#import "Balance+CoreDataProperties.h"
