//
//  DMLuaObjectReference.m
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "DMLuaObjectReference.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luajit.h"


@implementation DMLuaObjectReference
@synthesize ref, L;
- (void)dealloc
{
    luaL_unref(self.L, LUA_REGISTRYINDEX, self.ref);
}
@end
