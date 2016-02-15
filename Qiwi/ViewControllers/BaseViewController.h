//
//  BaseViewController.h
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) NSString *entityName;
@property (nonatomic, readonly) NSString *sortKey;
@property (nonatomic, readonly) NSString *cacheName;
@property (nonatomic, readonly) NSPredicate *predicate;
@property (nonatomic, readonly) void(^failureBlock)(RKObjectRequestOperation *operation, NSError *error);

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)requestData;

@end
