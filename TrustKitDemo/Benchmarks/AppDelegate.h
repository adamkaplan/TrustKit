//
//  AppDelegate.h
//  TrustKit-Benchmarks
//
//  Created by Adam Kaplan on 7/8/17.
//  Copyright © 2017 DataTheorem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) NSDictionary *trustKitConfig;

@end

