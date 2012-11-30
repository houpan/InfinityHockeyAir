//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "user_board.h"
#import "SimpleAudioEngine.h"
#import "ContactListener.h"
#import "QueryCallback.mm"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import <Foundation/Foundation.h>

//不知道為什麼一定要這邊存一個來讓他讀，直接讀HockeyTable裡面的就會炸掉
b2World * temp_world;

@implementation user_board



-(id) initWithWorld:(b2World*)world user_board_type:(user_board_type)user_board_type_input
{
	if ((self = [super initWithShape:@"user_board" inWorld:world]))
	{
        // set the parameters
        physicsBody->SetType(b2_dynamicBody);
        //控制讓他比較不容易旋轉
        physicsBody->SetAngularDamping(0.9f);
        user_board_type_Object=user_board_type_input;

        physicsBody->SetBullet(true);
        

        temp_world=world;
        // set random starting point
        [self setuser_boardStartPosition];
        
        // enable handling touches
		[[CCDirector sharedDirector].touchDispatcher addStandardDelegate:self priority:4 ];
        
        // schedule updates

	}
	return self;
}
+(id) user_boardWithWorld:(b2World*)world user_board_type:(user_board_type)user_board_type_input;
{

	return [[self alloc] initWithWorld:world user_board_type:user_board_type_input];
}

-(void) cleanup
{
	[super cleanup];
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

-(void) setuser_boardStartPosition
{
    // set the user_board's position
    //    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    //使用者的板子
    CGPoint startPos=CGPointMake(140, 140);
    //如果是敵人的話
    if(user_board_type_Object!=user_board_type_player){
        startPos = CGPointMake(300, 740);
    }
    
    
    physicsBody->SetTransform([Helper toMeters:startPos], 0.0f);
    physicsBody->SetLinearVelocity(b2Vec2_zero);
    physicsBody->SetAngularVelocity(0.0f);
}

-(void) applyForceTowardsFinger
{
	b2Vec2 bodyPos = physicsBody->GetWorldCenter();
	b2Vec2 fingerPos = [Helper toMeters:fingerLocation];
	
	b2Vec2 bodyToFingerDirection = fingerPos - bodyPos;
	bodyToFingerDirection.Normalize();
	
	b2Vec2 force = 50.0f * bodyToFingerDirection;
	
	// "Real" gravity falls off by the square over distance. Uncomment this code to see the effect:
	
    //	float distance = bodyToFingerDirection.Length();
    //	bodyToFingerDirection.Normalize();
    //	float distanceSquared = distance * distance;
    //	force = ((1.0f / distanceSquared) * 20.0f) * bodyToFingerDirection;
	
	
	physicsBody->ApplyForce(force, physicsBody->GetWorldCenter());
}


-(void) updateLocationData:(ccTime)delta
{

    
    double recently_time=CFAbsoluteTimeGetCurrent();

    time1+=CFAbsoluteTimeGetCurrent()-recently_time;
//    NSLog(@"+時間：%f,+地點：%f",CFAbsoluteTimeGetCurrent(),currentTouchLocation.x);
}

-(void) updateLocationOfBoard:(ccTime)delta
{
    
//Note:把CGpoint放進NSmutableArray的方法
//    NSArray *points = [NSArray arrayWithObjects:
//                       
//                       [NSValue valueWithCGPoint:CGPointMake(7.7, 8.8)], nil];
//    
//    NSValue *val = [points objectAtIndex:0];
//    CGPoint p = [val CGPointValue];
//    
    
    //判斷是否有超過，若超過的話就拿出下一個要跑的值給他跑


    if(![Helper compare:[[touchLocation objectAtIndex:0] CGPointValue] with:[[touchLocation objectAtIndex:1] CGPointValue]]||[touchLocation count]<3){
        [touchTime addObject:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]];
        [touchLocation addObject:[NSValue valueWithCGPoint:currentTouchLocation]];
    }
    
    double recently_time=CFAbsoluteTimeGetCurrent();
    double shouldTraveledDistance=[Helper distanceBetweenPoints:previousTouchLocation between:[[touchLocation objectAtIndex:0] CGPointValue]];
    double nowTraveldDistance=[Helper distanceBetweenPoints:previousTouchLocation between:[Helper toPixels:physicsBody->GetPosition()]];
    
//        NSLog(@"應該要跑的：%f,現在跑的：%f",shouldTraveledDistance,nowTraveldDistance);
    
    if((shouldTraveledDistance==0)
       ||
       (shouldTraveledDistance <= nowTraveldDistance)){
        
           
//           NSLog(@"進入更新態！");

        previousTouchLocation=[[touchLocation objectAtIndex:0] CGPointValue];
        //超過就先歸位
        physicsBody->SetTransform([Helper toMeters:previousTouchLocation], 0);

        [touchLocation removeObjectAtIndex:0];

        CGPoint differenceTouchLocation=[Helper subtract:[[touchLocation objectAtIndex:0] CGPointValue] of:previousTouchLocation];
//            NSLog(@"前一秒：%f,後一秒：%f",[[touchTime objectAtIndex:1] doubleValue],[[touchTime objectAtIndex:0] doubleValue]);
        
        double differenceTouchTime=[[touchTime objectAtIndex:1] doubleValue]-[[touchTime objectAtIndex:0] doubleValue];
        
        if(differenceTouchTime==0){
//            NSLog(@"0錯誤！");
            differenceTouchTime=0.0016;
        }
        
        [touchTime removeObjectAtIndex:0];
        
        CGPoint velocity_temp=[Helper divide:differenceTouchLocation by:differenceTouchTime];
        
//        NSLog(@"速度:%f",velocity_temp.x);
        if([Helper distanceBetweenPoints:previousTouchLocation between:[[touchLocation objectAtIndex:0] CGPointValue]]!=0){
            physicsBody->SetLinearVelocity([Helper toMeters:velocity_temp]);
        }

        
    }

    time2+=CFAbsoluteTimeGetCurrent()-recently_time;
//        NSLog(@"+時間1：%f,,時間2:%f",time1,time2);

}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    


    NSSet *allTouches = [event allTouches];

    //檢查這個地方有沒有這個物體存在
    for (UITouch* touch in allTouches)
	{
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        if(([Helper locationFromTouch:touch].y<=screenSize.height/2)&&user_board_type_Object==user_board_type_player){


//            NSLog(@"版拿到，我是%d",user_board_type_Object);
        //        [self schedule: @selector(update:) interval:0.016];
            
            touchLocation= [[NSMutableArray alloc]init];
            touchTime= [[NSMutableArray alloc]init];

            
            currentTouchLocation=[Helper locationFromTouch:touch];
            physicsBody->SetTransform([Helper toMeters:currentTouchLocation], 0);
            dragEnabled=YES;
            
            [touchTime addObject:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]];
            [touchTime addObject:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]];
                        [touchTime addObject:[NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()]];


                        [touchLocation addObject:[NSValue valueWithCGPoint:currentTouchLocation]];
                        [touchLocation addObject:[NSValue valueWithCGPoint:currentTouchLocation]];
            [touchLocation addObject:[NSValue valueWithCGPoint:currentTouchLocation]];
            previousTouchLocation=[[touchLocation objectAtIndex:0] CGPointValue];
            
//            [self schedule: @selector(updateLocationData:) interval:0.1];
            [self schedule: @selector(updateLocationOfBoard:) interval:0.016];

        }//這邊還沒寫敵人的情況
    }

    //如果回答NO，就不會繼續呼叫下面的move了
//    return isTouchHandled;
    
    
    
    
    
    
//
//    b2Vec2 pos = [Helper toMeters:[Helper locationFromTouch:touch]];
//    // Make a small box.
//    b2AABB aabb;
//    b2Vec2 d;
//    d.Set(0.001f, 0.001f);
//    aabb.lowerBound = pos - d;
//    aabb.upperBound = pos + d;
//    
//    // Query the world for overlapping shapes.
//    QueryCallback callback(pos);
////    [HockeyTableLayer sharedWorld]->QueryAABB(&callback, aabb);
//    temp_world->QueryAABB(&callback, aabb);
//
//    b2Body *body = callback.m_object;
//    if (body){
//        if([Helper locationFromTouch:touch])
//        CGSize screenSize = [CCDirector sharedDirector].winSize;
//        if(user_board_type_input)
//        NSLog(@"版被按到");
//    }
//    
//    //NSLog(@"版拿到");
//	moveToFinger = YES;
//	fingerLocation = [Helper locationFromTouch:touch];
//	return YES;
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    

    if(dragEnabled){
        NSSet *allTouches = [event allTouches];
        
        //檢查這個地方有沒有這個物體存在
        for (UITouch* touch in allTouches)
        {
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            if(([Helper locationFromTouch:touch].y<=screenSize.height/2)&&user_board_type_Object==user_board_type_player){

                

                
                
                currentTouchLocation=[Helper locationFromTouch:touch];



                
                
            }else if(([Helper locationFromTouch:touch].y>=screenSize.height/2)&&user_board_type_Object==user_board_type_enemy){
//                NSLog(@"版移動，我是%d，時間是%f",user_board_type_Object,(double)currentTouchTime);
                physicsBody->SetTransform([Helper toMeters:[Helper locationFromTouch:touch]], 0.0f);
                
            }
        }

        
    }
    
//	fingerLocation = [Helper locationFromTouch:touch];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(dragEnabled){
        dragEnabled=NO;
        
        NSSet *allTouches = [event allTouches];
        
        for (UITouch* touch in allTouches)
        {
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            if(([Helper locationFromTouch:touch].y<=screenSize.height/2)&&user_board_type_Object==user_board_type_player){
//                    NSLog(@"在這邊");
                physicsBody->SetLinearVelocity([Helper toMeters:[Helper makeIdentity]]);
                physicsBody->SetTransform([Helper toMeters:[Helper locationFromTouch:touch]], 0.0f);
            }
            [self unschedule: @selector(updateLocationData:)];
            [self unschedule: @selector(updateLocationOfBoard:)];

        }
        //基本上physicsBody只吃Meter，所以要給他的都要通過變成meter

    }
//    NSLog(@"版結束");
	moveToFinger = NO;
}

-(void) playSound
{
	float pitch = 0.9f + CCRANDOM_0_1() * 0.2f;
	float gain = 1.0f + CCRANDOM_0_1() * 0.3f;
	[[SimpleAudioEngine sharedEngine] playEffect:@"bumper.wav" pitch:pitch pan:0.0f gain:gain];
}

-(void) endContactWithBumper:(Contact*)contact
{
	[self playSound];
}

-(void) endContactWithPlunger:(Contact*)contact
{
	[self playSound];
}

@end
