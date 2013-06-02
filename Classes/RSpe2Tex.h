//
//  RSpe2Tex.h
//  RSpeech2TextDemo
//
//  Created by ricky on 13-6-1.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ERROR_DOMAIN @"org.rickytan.rspe2tex"

@class RSpe2Tex;

@protocol RSpe2TexDelegate <NSObject>
@optional
- (void)spe2Tex:(RSpe2Tex *)recogniser
recogniseDidFinishedWithText:(NSString*)text;
- (void)spe2Tex:(RSpe2Tex *)recogniser
recogniseDidFailedWithError:(NSError*)error;

@end

@interface RSpe2Tex : NSObject
@property (nonatomic, readonly, getter = isRecognizing) BOOL recognizing;
- (void)startRecogniseWithURL:(NSURL*)url
                     language:(NSString*)lang   // en,zh-CN,.... Default en
                  andDelegate:(id<RSpe2TexDelegate>)delegate;

@end
