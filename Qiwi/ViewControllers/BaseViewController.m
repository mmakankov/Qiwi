//
//  BaseViewController.m
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshItemDidClick:)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshItemDidClick:) forControlEvents:UIControlEventValueChanged];

    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)refreshItemDidClick:(id)sender {
    [self requestData];
    if ([sender isKindOfClass:[UIRefreshControl class]]) {
        [sender endRefreshing];
    }
}

#pragma mark - Data

- (void)requestData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"AlertButtonTitleOk", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    UIAlertAction* requestAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"AlertButtonTitleTryAgain", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestData];
    }];
    [alert addAction:requestAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Getters and Setters

- (NSString *)reuseIdentifier {
    NSAssert(YES, @"Error! This method must be overwritten");
    return nil;
}

- (NSString *)entityName {
    NSAssert(YES, @"Error! This method must be overwritten");
    return nil;
}

- (NSString *)sortKey {
    NSAssert(YES, @"Error! This method must be overwritten");
    return nil;
}

- (NSString *)cacheName {
    return nil;
}

- (NSPredicate *)predicate {
    return nil;
}

- (void (^)(RKObjectRequestOperation *, NSError *))failureBlock {
    __weak typeof(self) wself = self;
    void(^failureBlock)(RKObjectRequestOperation *, NSError *) =  ^(RKObjectRequestOperation *operation, NSError *error) {
        typeof(self) self = wself;
        [[MBProgressHUD HUDForView:self.view] hide:YES];
        [self showAlertWithTitle:[NSString stringWithFormat:@"Error code: %li", (long)error.code]
                         message:error.localizedDescription];
    };
    return failureBlock;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = self.predicate;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortKey ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:self.cacheName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
