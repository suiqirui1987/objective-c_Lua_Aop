//
//  DMLuaBridge.m
//  dm_ios_sdk
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "DMLuaBridge.h"
#include "DMLuaFun.h"


int finalize_object(lua_State *L)
{
    void *p = lua_touserdata(L, 1);
    void **ptr = (void**)p;
    id obj = (__bridge_transfer id)*ptr;
    NSLog(@"%s: releasing %@", __PRETTY_FUNCTION__, obj);

    return 0;
}

static NSUncaughtExceptionHandler * orig_exception_handler = NULL;
static NSString *exception_handler_opname = NULL;
static NSMutableArray *exception_handler_stack = NULL;

static void lua_exception_handler(NSException *exception)
{
    NSLog(@"Lua exception: opname = %@: stack = %@", exception_handler_opname, exception_handler_stack);
    if (orig_exception_handler) {
        orig_exception_handler(exception);
    }
}



@implementation DMLuaBridge

@synthesize L;

-(id)init{

    self = [super init];
    if (self) {
   
        L = luaL_newstate();
        luaL_openlibs(L);
      
        lua_newtable(L);
        

    
        LUA_ADDMETHOD(newstack);
        LUA_ADDMETHOD(push);
        LUA_ADDMETHOD(pop);
        LUA_ADDMETHOD(clear);
        LUA_ADDMETHOD(operate);
        LUA_ADDMETHOD(getclass);

        lua_setglobal(L, "objc");
        
        NSString *path =  [[NSBundle mainBundle] pathForResource:@"dmcore" ofType:@"lua"];
        NSLog(@"file: %@", path);
        if (luaL_dofile(L, [path UTF8String])) {
            const char *err = lua_tostring(L, -1);
            NSLog(@"error while loading utils: %s", err);
        }
    }
    
    
    return self;
}


+(DMLuaBridge*)instance{

    static DMLuaBridge *obj = NULL;
    if (!obj) {
        obj = [[DMLuaBridge alloc] init];
        
        lua_State *L = obj.L;
        lua_newtable(L);
        lua_pushstring(L, "__gc");
        lua_pushcfunction(L, finalize_object);
        lua_settable(L, -3);
        
        gc_metatable_ref = luaL_ref(L, LUA_REGISTRYINDEX);
        
        NSLog(@"%s: metatable_ref = %d", __PRETTY_FUNCTION__, gc_metatable_ref);
    }
    
    return obj;
}

- (void)op_call:(NSMutableArray*)stack
{
    NSString *message = (NSString*)[stack lastObject];
    [stack removeLastObject];
    id target = [stack lastObject] ;
    [stack removeLastObject];
    
  
    SEL sel = sel_getUid([message cStringUsingEncoding:NSUTF8StringEncoding]);

    
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    if (sig == nil) {
        NSLog(@" class %@ method %@ not exist",target,message);
        return;
    }
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv retainArguments];
    NSUInteger numarg = [sig numberOfArguments];
    //    NSLog(@"Number of arguments = %d", numarg);
    
    for (int i = 2; i < numarg; i++) {
        const char *t = [sig getArgumentTypeAtIndex:i];
        //        NSLog(@"arg %d: %s", i, t);
        id arg = [stack lastObject];
        [stack removeLastObject];
        
        switch (t[0]) {
            case 'c': // A char
            {
                char x = [(NSNumber*)arg charValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'i': // An int
            {
                int x = [(NSNumber*)arg intValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 's': // A short
            {
                short x = [(NSNumber*)arg shortValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'l': // A long l is treated as a 32-bit quantity on 64-bit programs.
            {
                long x = [(NSNumber*)arg longValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'q': // A long long
            {
                long long x = [(NSNumber*)arg longLongValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'C': // An unsigned char
            {
                unsigned char x = [(NSNumber*)arg unsignedCharValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'I': // An unsigned int
            {
                unsigned int x = [(NSNumber*)arg unsignedIntValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'S': // An unsigned short
            {
                unsigned short x = [(NSNumber*)arg unsignedShortValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'L': // An unsigned long
            {
                unsigned long x = [(NSNumber*)arg unsignedLongValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'Q': // An unsigned long long
            {
                unsigned long long x = [(NSNumber*)arg unsignedLongLongValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'f': // A float
            {
                float x = [(NSNumber*)arg floatValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'd': // A double
            {
                double x = [(NSNumber*)arg doubleValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'B': // A C++ bool or a C99 _Bool
            {
                int x = [(NSNumber*)arg boolValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
                
            case '*': // A character string (char *)
            {
                const char *x = [(NSString*)arg cStringUsingEncoding:NSUTF8StringEncoding];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case '@': // An object (whether statically typed or typed id)
                [inv setArgument:&arg atIndex:i];
                break;
                
            case '^': // pointer
                if ([arg isKindOfClass:[NSValue class]]) {
                    void *ptr = [(NSValue*)arg pointerValue];
                    [inv setArgument:&ptr atIndex:i];
                } else {
                    //[inv setArgument:&arg atIndex:i];
                    [NSError errorWithDomain:@"Passing wild pointer" code:1 userInfo:nil];
                }
                break;
                
                
            case 'v': // A void
            case '#': // A class object (Class)
            case ':': // A method selector (SEL)
            default:
                NSLog(@"%s: Not implemented", t);
                break;
        }
    }
    
    [inv setTarget:target];
    [inv setSelector:sel];
    [inv invoke];
    
    const char *rettype = [sig methodReturnType];
    //    NSLog(@"[%@ %@] ret type = %s", target, message, rettype);
    void *buffer = NULL;
    if (rettype[0] != 'v') { // don't get return value from void function
        NSUInteger len = [[inv methodSignature] methodReturnLength];
        buffer = malloc(len);
        [inv getReturnValue:buffer];
        //        NSLog(@"ret = %c", *(unichar*)buffer);
    }
#define CNVBUF(type) type x = *(type*)buffer
    
    switch (rettype[0]) {
        case 'c': // A char
        {
            CNVBUF(char);
            [stack addObject:[NSNumber numberWithChar:x]];
        }
            break;
        case 'i': // An int
        {
            CNVBUF(int);
            [stack addObject:[NSNumber numberWithInt:x]];
        }
            break;
        case 's': // A short
        {
            CNVBUF(short);
            [stack addObject:[NSNumber numberWithShort:x]];
        }
            break;
        case 'l': // A long l is treated as a 32-bit quantity on 64-bit programs.
        {
            CNVBUF(long);
            [stack addObject:[NSNumber numberWithLong:x]];
        }
            break;
        case 'q': // A long long
        {
            CNVBUF(long long);
            [stack addObject:[NSNumber numberWithLong:x]];
        }
            break;
        case 'C': // An unsigned char
        {
            CNVBUF(unsigned char);
            [stack addObject:[NSNumber numberWithUnsignedChar:x]];
        }
            break;
        case 'I': // An unsigned int
        {
            CNVBUF(unsigned int);
            [stack addObject:[NSNumber numberWithUnsignedInt:x]];
        }
            break;
        case 'S': // An unsigned short
        {
            CNVBUF(unsigned short);
            [stack addObject:[NSNumber numberWithUnsignedShort:x]];
        }
            break;
        case 'L': // An unsigned long
        {
            CNVBUF(unsigned long);
            [stack addObject:[NSNumber numberWithUnsignedLong:x]];
        }
            break;
        case 'Q': // An unsigned long long
        {
            CNVBUF(unsigned long long);
            [stack addObject:[NSNumber numberWithUnsignedLongLong:x]];
        }
            break;
        case 'f': // A float
        {
            CNVBUF(float);
            [stack addObject:[NSNumber numberWithFloat:x]];
        }
            break;
        case 'd': // A double
        {
            CNVBUF(double);
            [stack addObject:[NSNumber numberWithDouble:x]];
        }
            break;
        case 'B': // A C++ bool or a C99 _Bool
        {
            CNVBUF(int);
            [stack addObject:[NSNumber numberWithBool:x]];
        }
            break;
            
        case '*': // A character string (char *)
        {
            NSString *x = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
            [stack addObject:x];
        }
            break;
        case '@': // An object (whether statically typed or typed id)
        {
            id x = (__bridge id)*((void **)buffer);
            //            NSLog(@"stack %@", stack);
            if (x) {
                //                NSLog(@"x %@", x);
                [stack addObject:x];
            } else {
                [stack addObject:[NSNull null]];
            }
        }
            break;
            
        case '^':
        {
            void *x = *(void**)buffer;
            //            [stack addObject:[PointerObject pointerWithVoidPtr:x]];
            [stack addObject:[NSValue valueWithPointer:x]];
        }
            break;
        case 'v': // A void
            [stack addObject:[NSNull null]];
            break;
            
      
            
        case '#': // A class object (Class)
        case ':': // A method selector (SEL)
        default:
            NSLog(@"%s: Not implemented", rettype);
            [stack addObject:[NSNull null]];
            break;
    }
#undef CNVBUF
    
    free(buffer);
}



- (void)exec:(NSString*)opname onStack:(NSMutableArray*)stack{

    orig_exception_handler = NSGetUncaughtExceptionHandler();
    exception_handler_stack = stack;
    exception_handler_opname = opname;
    
    NSSetUncaughtExceptionHandler(lua_exception_handler);
    
    NSString *method = [NSString stringWithFormat:@"op_%@:", opname];
    
    SEL sel = sel_getUid([method cStringUsingEncoding:NSUTF8StringEncoding]);
    [self performSelector:sel withObject:stack];
    
    NSSetUncaughtExceptionHandler(orig_exception_handler);
    orig_exception_handler = NULL;
    exception_handler_stack = NULL;
    exception_handler_opname = NULL;
}

@end
