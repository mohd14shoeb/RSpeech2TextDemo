//
//  RDemoViewController.m
//  RSpeech2TextDemo
//
//  Created by ricky on 13-6-1.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RDemoViewController.h"
#import "RSpe2Tex.h"

#import <AVFoundation/AVFoundation.h>
//#import <CoreAudio/CoreAudioTypes.h>



@interface RDemoViewController () <AVAudioRecorderDelegate, RSpe2TexDelegate>
@property (nonatomic, retain) AVAudioRecorder *recorder;
@end

@implementation RDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view from its nib.
    if (!self.recorder) {
        NSString *file = @"speech.flac";
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                  nil];
        self.recorder = [[[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                     settings:nil
                                                        error:NULL] autorelease];
        self.recorder.delegate = self;
        [self.recorder prepareToRecord];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRecord:(id)sender
{
    if (self.recorder.isRecording) {
        [self.button setTitle:@"录音"
                     forState:UIControlStateNormal];
        [self.recorder stop];
    }
    else {
        if ([self.recorder record]) {
            NSLog(@"Start Recording...");
            [self.button setTitle:@"停止"
                         forState:UIControlStateNormal];
        }
        else {
            NSLog(@"Fail to Record!");
        }
    }
}

#pragma mark - AVRecorder Delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    if (flag) {
        RSpe2Tex *speech = [[RSpe2Tex alloc] init];
        [speech startRecogniseWithURL:recorder.url
                             language:nil
                          andDelegate:self];
    }
}

#pragma mark - RSpe2Tex Delegate

- (void)spe2Tex:(RSpe2Tex *)recogniser
recogniseDidFinishedWithText:(NSString*)text
{
    self.textView.text = text;
}

- (void)spe2Tex:(RSpe2Tex *)recogniser
recogniseDidFailedWithError:(NSError*)error
{
    NSLog(@"%@",error);
}

@end
