//
//  SettingsViewController.h
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIPickerView *timerPicker;

@property (weak, nonatomic) IBOutlet UISegmentedControl *scoreIncrementSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *negativeScoreSwitch;

- (IBAction)scoreIncrementDidChangeAction:(UISegmentedControl *)sender;
- (IBAction)soundSwitchDidChangeAction:(UISwitch *)sender;
- (IBAction)negativeScoreDidChangeAction:(UISwitch *)sender;

- (IBAction)clearAllDataSettingsAction:(UIButton *)sender;

@end
