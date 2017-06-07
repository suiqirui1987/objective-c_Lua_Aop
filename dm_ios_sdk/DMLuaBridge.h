//
//  DMLuaBridge.h
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "DMLuaCore.h"



@interface DMLuaBridge : NSObject
{
    lua_State *L;
}

@property (readonly) lua_State *L;

+(DMLuaBridge*)instance;


- (void)exec:(NSString*)opname onStack:(NSMutableArray*)stack;


@end
