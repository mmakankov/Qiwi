//
//  MasterViewController.m
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import "MainViewController.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "MainTableViewCell.h"

static NSString *mainTableViewCellIdentifier = @"MainTableViewCell";

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MainViewControllerTitle", nil);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil] forCellReuseIdentifier:mainTableViewCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestData {
    [super requestData];
    __weak typeof(self) wself = self;
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/mobile/testtask/index.json"
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                      typeof(self) self = wself;
                                                      [[MBProgressHUD HUDForView:self.view] hide:YES];
                                                      RKErrorMessage *errorCode = mappingResult.dictionary[@"result_code"];
                                                      if (![errorCode.errorMessage isEqualToString:@"0"]) {
                                                          RKErrorMessage *errorMessage = mappingResult.dictionary[@"errorMessage"];
                                                          [self showAlertWithTitle:[NSString stringWithFormat:@"Error code: %@", errorCode.errorMessage]
                                                                           message:errorMessage.errorMessage];
                                                      }
                                                  }
                                              failure:self.failureBlock];
}

#pragma mark - Getters and Setters

- (NSString *)reuseIdentifier {
    return mainTableViewCellIdentifier;
}

- (NSString *)entityName {
    return NSStringFromClass([User class]);
}

- (NSString *)sortKey {
    static NSString *sortKey = @"userId";
    return sortKey;
}

- (NSString *)cacheName {
    static NSString *mainCacheName = @"Main";
    return mainCacheName;
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DetailViewController *detailController = [[DetailViewController alloc] initWithNibName:NSStringFromClass([MainViewController class]) bundle:nil];
    detailController.managedObjectContext = self.managedObjectContext;
    detailController.user = user;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    MainTableViewCell *needCell = (MainTableViewCell *)cell;
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    needCell.idLabel.text = user.userId.stringValue;
    needCell.nameLabel.text = user.name;
}

@end
