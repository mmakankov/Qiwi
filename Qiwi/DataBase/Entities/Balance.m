//
//  Balance.m
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import "Balance.h"
#import "User.h"

@implementation Balance

// Insert code here to add functionality to your managed object subclass

- (NSString *)localizedValue {
   
    if ([self.currency isEqualToString:@"USD"]) {
        return [NSString stringWithFormat:@"$%@", self.amount];
    }
    if ([self.currency isEqualToString:@"RUB"]) {
        return [NSString stringWithFormat:@"%@ руб.", self.amount];
    }
    if ([self.currency isEqualToString:@"KZT"]) {
        return [NSString stringWithFormat:@"%@ т.", self.amount];
    }
    if ([self.currency isEqualToString:@"EUR"]) {
        return [NSString stringWithFormat:@"€%@", self.amount];
    }
    return nil;
}

@end
