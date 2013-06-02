//
//  RDemoViewController.h
//  RSpeech2TextDemo
//
//  Created by ricky on 13-6-1.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDemoViewController : UIViewController
@property (nonatomic, assign) IBOutlet UITextView *textView;
@property (nonatomic, assign) IBOutlet UIButton *button;
- (IBAction)onRecord:(id)sender;
@end
