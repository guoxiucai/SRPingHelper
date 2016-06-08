//
//  ViewController.m
//  SRPingHeplerTest
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 seewo. All rights reserved.
//

#import "ViewController.h"
#import "SRPingHelper.h"
#import "PingResultViewCell.h"
#import "PingResult.h"

static NSString *cellIdentifier = @"pingResultCell";

typedef NS_ENUM(NSInteger, PingOption) {
    PingOptionStart,
    PingOptionStop
};

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SRPingHelperDelegate>
{
    NSUInteger minRTT;
    NSUInteger maxRTT;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *pingButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *minRTTLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxRTTLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossRateLabel;

@property (nonatomic, strong) NSMutableArray *pingResults;

@property (nonatomic, strong) SRPingHelper *pingHelper;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pingHelper = [SRPingHelper sharedInstance];
    
    self.pingResults = [NSMutableArray array];
    
    maxRTT = 0;
    
    minRTT = 1000;
    
    [self.tableView reloadData];
    
    self.pingButton.tag = PingOptionStart;
    self.pingButton.tintColor = [UIColor greenColor];
    [self.pingButton setTitle:@"Ping" forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)pingButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (PingOptionStart == button.tag) {
        
        button.tag = PingOptionStop;
        button.tintColor = [UIColor redColor];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        
        [self.pingHelper setHost:self.textField.text];
        self.pingHelper.delegate = self;
        [self.pingHelper startPing];
        
        [self.textField endEditing:YES];
        
    } else if (PingOptionStop == button.tag) {
        
        button.tag = PingOptionStart;
        button.tintColor = [UIColor greenColor];
        [button setTitle:@"Ping" forState:UIControlStateNormal];
        
        [self.pingHelper stopPing];
        
        self.minRTTLabel.text = nil;
        self.maxRTTLabel.text = nil;
        self.lossRateLabel.text = nil;
        [self.pingResults removeAllObjects];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pingResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PingResultViewCell *cell = (PingResultViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PingResult *model = (PingResult *)[self.pingResults objectAtIndex:indexPath.row];
    
    [cell setCellModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}


#pragma mark - SRPingHelperDelegate

- (void)didReportSequence:(NSUInteger)seq timeout:(BOOL)isTimeout delay:(NSUInteger)delay packetLoss:(double)lossRate
{
    self.lossRateLabel.text = [NSString stringWithFormat:@"Loss:%.2f%%", lossRate];
    
    if (delay > maxRTT) {
        maxRTT = delay;
    }
    
    if (minRTT > delay) {
        minRTT = delay;
    }
    
    self.minRTTLabel.text = [NSString stringWithFormat:@"Min:%ldms", minRTT];
    self.maxRTTLabel.text = [NSString stringWithFormat:@"Max:%ldms", maxRTT];
    
    PingResult *result = [[PingResult alloc] initWithTimeout:isTimeout sequence:seq delay:delay host:self.textField.text];
    
    [self.pingResults addObject:result];
    
    
    [self.tableView reloadData];
    
}


@end
