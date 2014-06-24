//
//  APGasStationsTableVC.m
//  OilSavings
//
//  Created by Andi Palo on 6/23/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APGasStationsTableVC.h"
#import "APGasStation.h"
#import "APGSTableViewCell.h"

@interface APGasStationsTableVC ()

@end

@implementation APGasStationsTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    ALog("Table has %d rows", [self.gasStations count]);
    return [self.gasStations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier =@"gasStationCell";
    APGSTableViewCell *cell = (APGSTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        //cell = [[APTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GasStationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

// Customize the appearance of table view cells.
- (void)configureCell:(APGSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show path info
    APPath *path = [self.gasStations objectAtIndex:indexPath.row];
    
    cell.gsAddress.text = path.gasStation.name;
    cell.gsImage.image = [UIImage imageNamed:path.gasStation.logo];
    
    float price = [path.gasStation getPrice];
    int millesimal = ((int)(price * 1000)) % 10;
    
    cell.gsPrice.text = [NSString stringWithFormat:@"%4.2f",price];
    cell.gsMillesimal.text = [NSString stringWithFormat:@"%d",millesimal];
    
    int dist = [path getDistance];
    
    if (dist < 750) {
        cell.gsDistance.text = [NSString stringWithFormat:@"%d m", dist];
    } else {
        float distKM = dist / 1000;
        cell.gsDistance.text = [NSString stringWithFormat:@"%2.1f Km", distKM];
    }
    
    int time = [path getTime];
    cell.gsTime.text = [NSString stringWithFormat:@"%d min", (int)(time / 60)];
    
    cell.gsFuelRecharge.text = [NSString stringWithFormat:@"%3.1f L", [path getFuelExpense]];
    cell.path = path;
    
//    Add target for press
//    [cell.infoButton addTarget:self action:@selector(startInfoPush:) forControlEvents:UIControlEventTouchUpInside];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
