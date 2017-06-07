//
//  ViewController.m
//  dm_ios_sdk_demo
//
//  Created by qiruisun on 17/6/1.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "ViewController.h"
#include  "DMLuaClass.h"


@interface ViewController ()
{
   
    DMLuaClass *lua_class;
}
@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
     
        lua_class = [[DMLuaClass alloc] initWithClassName:@"ViewController"];
        [lua_class aspect:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    __weak id weakSelf = self;
    [self aspect_hookSelector:@selector(imgclick) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        NSLog(@"View Controller %@ will imgclick", aspectInfo.instance);
        
       /*
        __strong id strongSelf = weakSelf;
        
        NSMutableArray *stack = [[NSMutableArray alloc]init];
        [stack addObject:strongSelf];
        [stack addObject:@"viewDidload"];
        [lua_class call:@"viewDidLoad" stack:stack];
        
        */
        
    } error:NULL];
    
    [self aspect_hookSelector:@selector(Test:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, NSString* txt) {
        NSLog(@"View Controller %@ will Test: %@", aspectInfo.instance, txt);
        

    } error:NULL];
    
    
    
    
    
    
    UIButton *btn1=[[UIButton alloc]initWithFrame:CGRectMake(20, 100, 50, 25)];
    [btn1 setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [btn1 setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateNormal];
    [btn1 setTitle:@"加载" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(imgclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    
    UIButton *btn2=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50, 25)];
    [btn2 setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [btn2 setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateNormal];
    [btn2 setTitle:@"加载2" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(imgclick2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
  
    
   

    

    

    
    // Do any additional setup after loading the view, typically from a nib.
}
-(NSString*)Test:(NSString*)txt{
    

    NSLog(@"%@ %s",txt,__FUNCTION__);
    
    NSMutableArray *imgclickstack = [[NSMutableArray alloc]init];
    [imgclickstack addObject:@"efb-Test"];
    [lua_class call:@"imgclick"  stack:imgclickstack];
    
    
    return @"ok";
}
-(void)imgclick{
  
    NSLog(@"objc imgclick");
}

-(void)imgclick2{
    NSLog(@"objc imgclick2");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
