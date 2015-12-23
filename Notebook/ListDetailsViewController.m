//
//  ListDetailsViewController.m
//  Notebook
//
//  Created by Smbat Tumasyan on 12/22/15.
//  Copyright © 2015 EGS. All rights reserved.
//

#import "ListDetailsViewController.h"

@interface ListDetailsViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

@end

@implementation ListDetailsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleTextField setEnabled:NO];
    [self.detailsTextView setEditable:NO];
    self.titleTextField.text = self.listDetails.title;
    self.detailsTextView.text = self.listDetails.details;
    self.navigationItem.title = [NSDateFormatter localizedStringFromDate:self.listDetails.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (IBAction)editButtonAction:(UIBarButtonItem *)sender {
    
    if (self.titleTextField.enabled == NO) {
        [self.titleTextField setEnabled:YES];
        [self.detailsTextView setEditable:YES];
        sender.title = @"Done";
 
    } else {
        [self.titleTextField setEnabled:NO];
        [self.detailsTextView setEditable:NO];
        sender.title = @"Edit";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end