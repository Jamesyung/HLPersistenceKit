//
//  AppDelegate.m
//  HLPersistenceKitDemo
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import "AppDelegate.h"
#import "HLPersistenceManager.h"
#import "HLPersistenceConfiguration.h"
#import "HLPersistenceBaseConfigurationItem.h"
#import "HLPersistenceFileConfigurationItem.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (nonnull NSString *)pathForVisualizationFile {
    return [[NSBundle mainBundle] pathForResource:@"ConfigurationDemoList" ofType:@"plist"];
}

- (nonnull HLPersistenceConfiguration *)configuredInstance {
    HLPersistenceConfiguration *config = [HLPersistenceConfiguration new];
    
    HLPersistenceBaseConfigurationItem *item = [HLPersistenceBaseConfigurationItem new];
    item.persistenceKey = @"keyA";
    item.persistenceType = HLPersistenceTypeUserDefaults;
    
    [config addItems:@{@"keyA":item}];
    
    return config;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [HLPersistenceManager sharedManager].delegate = self;
    
    
    [[HLPersistenceManager sharedManager] objectForKey:@""];
    [[HLPersistenceManager sharedManager] objectForKey:nil];
    [[HLPersistenceManager sharedManager] setObject:@"" forKey:@""];
    [[HLPersistenceManager sharedManager] setObject:nil forKey:@"keyB"];
    
    id object = [[HLPersistenceManager sharedManager] objectForKey:@"keyA"];
    if (!object) {
        [[HLPersistenceManager sharedManager] setObject:@"hhhhhhh" forKey:@"keyA"];
    }
    
    object = [[HLPersistenceManager sharedManager] objectForKey:@"keyb"];
    
    object = [[HLPersistenceManager sharedManager] objectForKey:@"keyB"];
    if (!object) {
        [[HLPersistenceManager sharedManager] setObject:@"bbbbbbb" forKey:@"keyB"];
    }
    object = [[HLPersistenceManager sharedManager] objectForKey:@"keyB"];
    
    for (NSInteger index = 0; index < 1000; index++) {
        object = [[HLPersistenceManager sharedManager] objectForKey:@"keyC"];
        if (!object) {
            [[HLPersistenceManager sharedManager] setObject:@"CADDSAD" forKey:@"keyC"];
        }
        object = [[HLPersistenceManager sharedManager] objectForKey:@"keyD"];
        if (!object) {
            [[HLPersistenceManager sharedManager] setObject:@"DDDDDDD" forKey:@"keyD"];
        }
    }
    
    [[HLPersistenceManager sharedManager] setObject:[HLPersistenceFileConfigurationItem new] forKey:@"keyC"];
    object = [[HLPersistenceManager sharedManager] objectForKey:@"keyB"];
    
    
    dispatch_queue_t concurrentqueue = dispatch_queue_create("hello.lujah", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger index = 0; index < 10; index ++) {
        dispatch_async(concurrentqueue, ^{
            
            if (index%3 == 0) {
                [[HLPersistenceManager sharedManager] setObject:@"bbbb" forKey:@"keyC"];
                NSLog(@"\n\n ----- %@ ------ \n bbbb\n\n",[NSThread currentThread]);
            }
            
            if (index%3 == 1) {
                [[HLPersistenceManager sharedManager] setObject:@"aaaa" forKey:@"keyC"];
                NSLog(@"\n\n ----- %@ ------ \n aaaa\n\n",[NSThread currentThread]);
            }
            
            if (index%3 == 2) {
                id oneObject = [[HLPersistenceManager sharedManager] objectForKey:@"keyC"];
                NSLog(@"\n\n ----- %@ ------ \n get object = %@\n\n",[NSThread currentThread],oneObject);
            }
        });
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"HLPersistenceKitDemo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
