//
//  NoteListViewController.m
//  Notebook
//
//  Created by Smbat Tumasyan on 12/22/15.
//  Copyright © 2015 EGS. All rights reserved.
//

#import "NoteListViewController.h"
#import "ListDetailsViewController.h"
#import "NoteListViewCell.h"
#import "NBCoreDataManager.h"

@interface NoteListViewController ()

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NBDataModel *list;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isAddButtonPressed;


@property (nonatomic, strong) NBCoreDataManager *wrapper;

@end

@implementation NoteListViewController

- (void)viewWillAppear:(BOOL)animated {
    self.tableData = [self.wrapper findAllList];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Notebook";
    self.wrapper = [NBCoreDataManager sharedInstance];
}
- (IBAction)addButtonAction:(UIBarButtonItem *)sender {
    self.isAddButtonPressed = YES;
    [self performSegueWithIdentifier:@"NoteListViewController" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"tableIdenfier";
    NoteListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[NoteListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    self.list = self.tableData[indexPath.row] ;
    cell.titleLabel.text = self.list.title;
    cell.detailsLabel.text = self.list.details;
    cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.list.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"NoteListViewController" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
     ListDetailsViewController *vc = [segue destinationViewController];
    if (self.isAddButtonPressed) {
        vc.isAddButtonPressed = YES;
        self.isAddButtonPressed = NO;
    } else if ([[segue identifier] isEqualToString:@"NoteListViewController"]) {
        vc.listDetails = self.tableData[selectedIndexPath.row];
    }
}

@end
