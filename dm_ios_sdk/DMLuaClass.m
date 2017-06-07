//
//  DMLuaClass.m
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/3.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "DMLuaClass.h"
#import "DMLuaFun.h"
#import "Aspects.h"
@interface DMLuaClass(){

    NSString *classname_;
    DMLuaBridge *luabridge_;
    lua_State *L;
}
@end
@implementation DMLuaClass


-(id)initWithClassName:(NSString*)classname{

    self = [super init];
    if (self) {
        classname_ = classname;
        luabridge_ = [DMLuaBridge instance];
        L = [luabridge_ L];
        
        NSString *fn = [[NSBundle mainBundle] pathForResource:classname_ ofType:@"lua"];
        NSLog(@"file: %@", fn);
        if (luaL_dofile(L, [fn UTF8String])) {
            NSLog(@"Lua Error: %s", lua_tostring(L, -1));
        }
        
      
    }
    
    return self;

}

void PrintTable(lua_State *L)
{
    lua_pushnil(L);
    
    while(lua_next(L, -2) != 0)
    {
        if(lua_isstring(L, -1))
            printf("s %s = %s\n", lua_tostring(L, -2), lua_tostring(L, -1));
        else if(lua_isnumber(L, -1))
            printf("n %s = %f\n", lua_tostring(L, -2), lua_tonumber(L, -1));
        else if(lua_istable(L, -1))
        {
            printf("table\s");
            PrintTable(L);
        }
        else if(lua_isfunction(L, -1))
             printf("function %s = %s\n", lua_tostring(L, -2), lua_tostring(L, -1));
       
        lua_pop(L, 1);
    }
}


-(void)call:(NSString*)method  stack:(NSMutableArray*)stack{
    
    lua_getglobal(L, [classname_ UTF8String]);
    if (!lua_istable(L, -1)){
        NSLog(@"`%@' is not a valid  table,",classname_);
        return;
    }
   // PrintTable(L);

    lua_getfield(L, -1, [method UTF8String]);
    
    int stack_count = 0;
    if (stack != nil) {
        
        for (int i=0; i<stack.count;i++) {
            id obj = stack[i];
            luabridge_push_object(L,obj);
        }
        stack_count = stack.count;
    }
    
    if (lua_pcall(L, stack_count, 1, 0)) {
        NSLog(@"Lua Error: %s", lua_tostring(L, -1));
    }
    
    

}



-(void)aspect:(id)obj{
/*


 */

    NSString *aspect_string = [NSString stringWithFormat:@"%@_Aspect", classname_];
    lua_getglobal(L, [aspect_string UTF8String]);
    if (!lua_istable(L, -1)){
        NSLog(@"`%@' is not a valid  table,",aspect_string);
        return;
    }

    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        
        if(!lua_istable(L, -1))
        {
            NSLog(@"aspect is not a valid  table,");
            break;;
        }
        
    
 
        lua_pushstring(L, "event");
        lua_gettable(L, -2);
        char* k_methodname = lua_tostring(L,-1);
        lua_pop(L, 1);
        
        if (k_methodname == NULL) {
            NSLog(@"k_methodname is not a valid  key,");
            break;;;
        }
        
        
        
     
        lua_pushstring(L, "handler");
        lua_gettable(L, -2);
        char* v_methodname = lua_tostring(L,-1);
        if (v_methodname == NULL) {
            NSLog(@"v_methodname is not a valid  key,");
            break;;;
        }
        lua_pop(L, 1);
        
        lua_pushstring(L, "type");
        lua_gettable(L, -2);
        int v_type = lua_tointeger(L,-1);
        lua_pop(L, 1);
        
        
        
        if (v_methodname == NULL) {
            NSLog(@"v_methodname is not a valid  val,");
            break;;;
        }
     
        
        NSString *objc_methodname = [NSString stringWithUTF8String:k_methodname];
        
        NSString *lua_methodname = [NSString stringWithUTF8String:v_methodname];
        
     
         
         SEL selekor = NSSelectorFromString(objc_methodname);
        
         
         __weak id weakSelf = self;
        [obj aspect_hookSelector:selekor withOptions:v_type usingBlock:^(id<AspectInfo> aspectInfo) {
            NSLog(@" aspect_hookSelector objcm %@ luam  %@", objc_methodname, lua_methodname);
            
            
            
            __strong id strongSelf = weakSelf;
            NSMutableArray *stack = [[NSMutableArray alloc]init];
            [stack addObject:obj];
            for (int i=0; i<aspectInfo.arguments.count; i++) {
                [stack addObject:aspectInfo.arguments[i]];
            }
            [strongSelf call:lua_methodname stack:stack];
            
            
            
        } error:NULL];
    

        lua_pop(L, 1);
    }

}

@end
