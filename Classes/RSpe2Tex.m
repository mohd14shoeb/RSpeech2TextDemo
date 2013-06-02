//
//  RSpe2Tex.m
//  RSpeech2TextDemo
//
//  Created by ricky on 13-6-1.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RSpe2Tex.h"

static NSString *recognise_server = @"https://www.google.com/speech-api/v1/recognize?client=chrome&maxresults=10&key=as&lang=%@";

@interface RSpe2Tex () <NSURLConnectionDelegate>
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) id<RSpe2TexDelegate> delegate;
@end

@implementation RSpe2Tex

#pragma mark - Methods

- (NSURL*)hostWithLanguage:(NSString*)lang
{
    lang = (lang == nil) ? @"en-US":lang;
    NSString *urlStr = [NSString stringWithFormat:recognise_server, lang];
    return [NSURL URLWithString:urlStr];
}

#pragma mark - Public Methods

- (void)startRecogniseWithURL:(NSURL *)url
                     language:(NSString *)lang
                  andDelegate:(id<RSpe2TexDelegate>)delegate
{
    if (self.isRecognizing)
        return;
    
    self.url = url;
    self.delegate = delegate;
    
    __block void(^sendRequestWithData)(NSData *data) = ^(NSData *data) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self hostWithLanguage:lang]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:@"audio/x-flac; rate=16000"
       forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"Keep-Alive"
       forHTTPHeaderField:@"Connection"];
        [request addValue:@"no-cache"
       forHTTPHeaderField:@"Pragma"];
        [request addValue:@"no-cache"
       forHTTPHeaderField:@"Cache-Control"];
        [request addValue:@"*/*"
       forHTTPHeaderField:@"Accept"];
        [request addValue:@"http://www.google.com"
       forHTTPHeaderField:@"Referer"];
        [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31"
       forHTTPHeaderField:@"User-Agent"];
        
        NSLog(@"%@",request.allHTTPHeaderFields);
        
        //        NSMutableData *postData = [NSMutableData dataWithData:[@"Content=" dataUsingEncoding:NSASCIIStringEncoding]];
        //        [postData appendData:data];
        [request setHTTPBody:data];
        [request setTimeoutInterval:10.0];

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                                   _recognizing = NO;
                                   
                                   if (e) {
                                       if ([self.delegate respondsToSelector:@selector(spe2Tex:recogniseDidFailedWithError:)])
                                           [self.delegate spe2Tex:self
                                      recogniseDidFailedWithError:e];
                                   }
                                   else {
                                       int statusCode = ((NSHTTPURLResponse*)r).statusCode;
                                       NSLog(@"%@",d);
                                       char *ch = (char*)malloc(d.length + 1);
                                       memcpy(ch, d.bytes, d.length);
                                       ch[d.length] = 0;
                                       NSString *text = [NSString stringWithCString:ch
                                                                           encoding:NSUTF8StringEncoding];
                                       if (!text)
                                           text = [NSString stringWithCString:ch
                                                                     encoding:NSASCIIStringEncoding];
                                       NSLog(@"%@",text);
                                       free(ch);
                                       if (statusCode == 200) {
                                           if ([self.delegate respondsToSelector:@selector(spe2Tex:recogniseDidFinishedWithText:)])
                                               [self.delegate spe2Tex:self
                                         recogniseDidFinishedWithText:[NSString stringWithUTF8String:d.bytes]];
                                       }
                                       else {
                                           if ([self.delegate respondsToSelector:@selector(spe2Tex:recogniseDidFailedWithError:)]) {
                                               e = [NSError errorWithDomain:ERROR_DOMAIN
                                                                       code:statusCode
                                                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:text, @"message", nil]];
                                               [self.delegate spe2Tex:self
                                          recogniseDidFailedWithError:e];
                                           }
                                       }
                                   }
                               }];
    };
    
    _recognizing = YES;
    
    if (url.isFileURL) {
        sendRequestWithData([NSData dataWithContentsOfFile:url.path]);
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                                   if (e) {
                                       _recognizing = NO;
                                       
                                       if ([self.delegate respondsToSelector:@selector(spe2Tex:recogniseDidFailedWithError:)])
                                           [self.delegate spe2Tex:self
                                      recogniseDidFailedWithError:e];
                                   }
                                   else {
                                       sendRequestWithData(d);
                                   }
                               }];
    }
}

@end
