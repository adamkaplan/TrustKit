//
//  AppDelegate.m
//  TrustKit-Benchmarks
//
//  Created by Adam Kaplan on 7/8/17.
//  Copyright © 2017 DataTheorem. All rights reserved.
//

#import "AppDelegate.h"
#import <TrustKit/TSKTrustKitConfig.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _trustKitConfig =
    @{
      // Do not auto-swizzle NSURLSession delegates
      kTSKSwizzleNetworkDelegates: @NO,
      
      kTSKPinnedDomains: @{
              
              // Pin invalid SPKI hashes to *.yahoo.com to demonstrate pinning failures
              @"yahoo.com": @{
                      kTSKEnforcePinning: @YES,
                      kTSKIncludeSubdomains: @YES,
                      kTSKPublicKeyAlgorithms: @[kTSKAlgorithmRsa2048],
                      
                      // Wrong SPKI hashes to demonstrate pinning failure
                      kTSKPublicKeyHashes: @[
                              @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                              @"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
                              ],
                      
                      // Send reports for pinning failures
                      // Email info@datatheorem.com if you need a free dashboard to see your App's reports
                      kTSKReportUris: @[@"https://overmind.datatheorem.com/trustkit/report"]
                      },
              
              
              // Pin valid SPKI hashes to www.datatheorem.com to demonstrate success
              @"www.datatheorem.com" : @{
                      kTSKEnforcePinning:@YES,
                      kTSKPublicKeyAlgorithms : @[kTSKAlgorithmEcDsaSecp384r1],
                      
                      // Valid SPKI hashes to demonstrate success
                      kTSKPublicKeyHashes : @[
                              @"58qRu/uxh4gFezqAcERupSkRYBlBAvfcw7mEjGPLnNU=", // CA key: COMODO ECC Certification Authority
                              @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", // Fake key but 2 pins need to be provided
                              ]
                      }}};
    
    return YES;
}

@end
