//
//  DMLuaFun.m
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "DMLuaFun.h"
#import <objc/runtime.h>  

#import "DMLuaObjectReference.h"
#import "DMLuaBridge.h"


void luabridge_push_object(lua_State *L, id obj)
{
    if (obj == nil) {
        lua_pushnil(L);
    } else if ([obj isKindOfClass:[NSString class]]) {
        lua_pushstring(L, [obj cStringUsingEncoding:NSUTF8StringEncoding]);
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        lua_pushnumber(L, [obj doubleValue]);
    } else if ([obj isKindOfClass:[NSNull class]]) {
        lua_pushnil(L);
    } else if ([obj isKindOfClass:[DMLuaObjectReference class]]) {
        int ref = ((DMLuaObjectReference*)obj). ref;
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
    } else {
        
        
        void *ud = lua_newuserdata(L, sizeof(void*));
        void **udptr = (void**)ud;
        *udptr = (__bridge_retained void *)(obj);
        lua_rawgeti(L, LUA_REGISTRYINDEX, gc_metatable_ref);
        lua_setmetatable(L, -2);
    }
}




/**
 
 LUA to C++
 **/

int luafunc_newstack(lua_State *L){
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    lua_pushlightuserdata(L, (__bridge_retained void *)(arr));
    return 1;
}
int luafunc_push(lua_State *L){
    int top = lua_gettop(L);
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    for (int i=2; i<=top; i++) {
        int type = lua_type(L, i);
        switch (type) {
            case LUA_TNIL:
                [arr addObject:[NSNull null]];
                break;
            case LUA_TNUMBER:
                [arr addObject:[NSNumber numberWithDouble:lua_tonumber(L, i)]];
                break;
            case LUA_TBOOLEAN:
                [arr addObject:[NSNumber numberWithBool:lua_toboolean(L, i)]];
                break;
            case LUA_TSTRING:
                [arr addObject:[NSString stringWithCString:lua_tostring(L, i) encoding:NSUTF8StringEncoding]];
                break;
            case LUA_TLIGHTUSERDATA:
                [arr addObject:(__bridge id)lua_topointer(L, i)];
                break;
            case LUA_TUSERDATA:
            {
                void *p = lua_touserdata(L, i);
                void **ptr = (void**)p;
                [arr addObject:(__bridge id)*ptr];
            }
                break;
            case LUA_TTABLE:
            case LUA_TFUNCTION:
            case LUA_TTHREAD:
            {
                DMLuaObjectReference *ref = [DMLuaObjectReference new];
                ref.ref = luaL_ref(L, LUA_REGISTRYINDEX);
                ref.L = L;
                [arr addObject:ref];
            }
                break;
            case LUA_TNONE:
            default:
            {
                NSString *errmsg = [NSString stringWithFormat:@"Value type not supported. type = %d", type];
                lua_pushstring(L, [errmsg UTF8String]);
                lua_error(L);
            }
        }
    }
    
    return 1;
}
int luafunc_pop(lua_State *L){
    
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    id obj = [arr lastObject];
    [arr removeLastObject];
    
    
    luabridge_push_object(L, obj);
    return 1;
}
int luafunc_clear(lua_State *L){

    NSMutableArray *arr = (__bridge NSMutableArray*)lua_topointer(L, 1);
    [arr removeAllObjects];
    
    return 1;
}
int luafunc_operate(lua_State *L){

    NSMutableArray *arr = (__bridge NSMutableArray*)lua_topointer(L, 1);
    NSString *opname = [NSString stringWithCString:lua_tostring(L, 2) encoding:NSUTF8StringEncoding];
    
    [[DMLuaBridge instance] exec:opname onStack:arr];
    
    return 1;
}
int luafunc_getclass(lua_State *L){

    const char *cls_name = lua_tostring(L, -1);
    id cls = objc_getClass(cls_name);
    lua_pushlightuserdata(L, (__bridge void *)(cls));
    return 1;
}