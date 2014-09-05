//
//  APLegalViewController.m
//  OilSavings
//
//  Created by Andi Palo on 9/5/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APLegalViewController.h"

@interface APLegalViewController ()
@property (weak, nonatomic) IBOutlet UIWebView* mainText;
@end

@implementation APLegalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mainText.backgroundColor = [UIColor clearColor];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    //    ALog("base path is: %@",path);
    [self.mainText loadHTMLString:htmlString baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
