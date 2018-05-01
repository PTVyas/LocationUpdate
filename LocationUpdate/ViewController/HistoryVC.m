//
//  HistoryVC.m
//  LocationUpdate
//
//  Created by WOS_MacMini_1 on 26/04/18.
//  Copyright © 2018 White Orange Software. All rights reserved.
//

#import "HistoryVC.h"

@interface HistoryVC () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *arrData;
}
@end

@implementation HistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrData = [[NSMutableArray alloc] init];
    
    [self getLocationData];
    [self manage_ReloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) manage_ReloadData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(05.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getLocationData];
        [self manage_ReloadData];
    });
}
- (void) getLocationData {
    arrData = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUD_DataKey = @"data".uppercaseString;
    arrData = [userDefaults objectForKey:strUD_DataKey];
    
    [self.tblHistory reloadData];
    
    //Move on Last Cell
    if (arrData.count == 0)
        return;
    
    //int lastRowNumber = arrData.count - 1;
    //NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    //[self.tblHistory scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:false];
}

#pragma mark - Button Action Methods
- (IBAction)btnBackAction {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)btnRemoveAllAction {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUD_DataKey = @"data".uppercaseString;
    [userDefaults removeObjectForKey:strUD_DataKey];
    
    [self btnBackAction];
}

#pragma mark - Tableview Cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    dicData = [arrData objectAtIndex:indexPath.row];
    NSString *strTitle = [dicData valueForKey:@"1"];
    NSString *strSubTitle = [dicData valueForKey:@"2"];
    
    cell.textLabel.text = strTitle;
    cell.detailTextLabel.text = strSubTitle;
    
    return cell;
}
@end
