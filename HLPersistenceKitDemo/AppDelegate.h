//
//  AppDelegate.h
//  HLPersistenceKitDemo
//
//  Created by yanglihua on 2017/11/23.
//  Copyright © 2017年 WayToHelloLujah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

