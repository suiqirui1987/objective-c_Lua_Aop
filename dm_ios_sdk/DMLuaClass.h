//
//  DMLuaClass.h
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/3.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMLuaBridge.h"

@interface DMLuaClass : NSObject

-(id)initWithClassName:(NSString*)classname;


-(void)aspect:(id)obj;
-(void)call:(NSString*)method  stack:(NSMutableArray*)stack;

@end
