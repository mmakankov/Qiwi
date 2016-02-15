//
//  DetailViewController.m
//  Qiwi
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 mmakankov. All rights reserved.
//

#import "DetailViewController.h"
#import "MainTableViewCell.h"
#import "MBProgressHUD.h"
#import "Balance.h"
#import "User.h"
#import "DataBaseManager.h"

static NSString *mainTableViewCellIdentifier = @"MainTableViewCell";

@interface DetailViewController ()

@property (nonatomic, strong) NSArray *balanceArray;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"BalanceViewControllerTitle", nil);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil] forCellReuseIdentifier:mainTableViewCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestData {
    [super requestData];
    __weak typeof(self) wself = self;
    [[RKObjectManager sharedManager] getObjectsAtPathForRelationship:@"balances"
                                                            ofObject:self.user
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
                                                                 else {
                                                                     for (Balance *balance in mappingResult.dictionary[@"balances"]) {
                                                                         balance.user = self.user;
                                                                     }
                                                                 }
                                                                 
                                                             }
                                                             failure:self.failureBlock];
}

#pragma mark - Table View

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    MainTableViewCell *needCell = (MainTableViewCell *)cell;
    Balance *balance = [self.fetchedResultsController objectAtIndexPath:indexPath];
    needCell.nameLabel.text = balance.localizedValue;
}


#pragma mark - Getters and Setters

- (NSString *)reuseIdentifier {
    return mainTableViewCellIdentifier;
}

- (NSString *)entityName {
    return NSStringFromClass([Balance class]);
}

- (NSString *)sortKey {
    static NSString *sortKey = @"amount";
    return sortKey;
}

- (NSString *)cacheName {
    return [NSString stringWithFormat:@"userId_%@", self.user.userId];
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"user.userId == %@", self.user.userId];
}

@end
