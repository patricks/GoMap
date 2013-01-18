//
//  AppDelegate.m
//  OSMiOS
//
//  Created by Bryce on 12/6/12.
//  Copyright (c) 2012 Bryce. All rights reserved.
//

#import "AppDelegate.h"
#import "DownloadThreadPool.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	self.userName		= [defaults objectForKey:@"username"];
	self.userPassword	= [defaults objectForKey:@"password"];

	[DownloadThreadPool setUserAgent:[NSString stringWithFormat:@"%@/%@", self.appName, self.appVersion]];

	return YES;
}

- (NSString *)appName
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

- (NSString *)appVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.userName		forKey:@"username"];
	[defaults setObject:self.userPassword	forKey:@"password"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
