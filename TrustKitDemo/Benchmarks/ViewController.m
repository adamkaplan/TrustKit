//
//  ViewController.m
//  TrustKit-Benchmarks
//
//  Created by Adam Kaplan on 7/8/17.
//  Copyright © 2017 DataTheorem. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <TrustKit/TrustKit.h>
#import <TrustKit/TSKPinningValidator.h>
#import <mach/mach_time.h>
#import <sys/kdebug_signpost.h>

@interface ViewController () <NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *benchmarkSuccessButton;
@property (weak, nonatomic) IBOutlet UIButton *benchmarkFailureButton;
@property (nonatomic) TrustKit *trustKit;
@property (nonatomic) NSURLSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                 delegate:self
                                            delegateQueue:NSOperationQueue.mainQueue];
    
    self.trustKit = [[TrustKit alloc] initWithConfiguration:((AppDelegate *)UIApplication.sharedApplication.delegate).trustKitConfig];
    // TODO: set validation callback queue?
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    
    [TrustKit setLoggerBlock:^(NSString * _Nonnull str) {
        NSLog(@"%@", str);
    }];
    
    TSKPinningValidator *pinningValidator = self.trustKit.pinningValidator;
    
    void(^noopCompletionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential *) = ^(NSURLSessionAuthChallengeDisposition d, NSURLCredential *c) {
        //
    };
    
    NSTimeInterval duration = [self time:^{
        for (int i = 0; i < 1000; i++) {
            [pinningValidator handleChallenge:challenge completionHandler:noopCompletionHandler];
        }
    }];
    NSLog(@"Took %0.4fms per 1000 evaluations", duration * 1000);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:NO completion:nil];
}

#pragma mark Benchmarks

- (IBAction)benchmarkPinSuccess:(UIButton *)sender
{
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:@"https://www.datatheorem.com/"]];
    [task resume];
}

- (IBAction)benchmarkPinFailure:(UIButton *)sender
{
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:@"https://www.yahoo.com/"]];
    [task resume];
}

- (NSTimeInterval)time:(void(^)(void))block
{
    kdebug_signpost_start(0xFF, 0, 0, 0, 0);
    uint64_t start = mach_absolute_time();
    block();
    uint64_t end = mach_absolute_time();
    kdebug_signpost_end(0xFF, 0, 0, 0, 0);
    
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);
    uint64_t nanos = (end - start) * timebase_info.numer / timebase_info.denom;
    return nanos / (double)NSEC_PER_SEC;
}

@end
