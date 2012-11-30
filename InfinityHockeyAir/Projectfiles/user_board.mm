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
#import "ScoreBoard.h"
#import "ItemAdder.h"
#import "Ball.h"
#import "ParticleEffectAdder.h"
#import "user_boardAdder.h"
#import <Foundation/Foundation.h>

//不知道為什麼一定要這邊存一個來讓他讀，直接讀HockeyTable裡面的就會炸掉
b2World * temp_world;

@implementation user_board



-(id) initWithWorld:(b2World*)world user_board_type:(user_board_type)user_board_type_input andSpecialBoardType:(specialBoardType)specialBoardTypeInput
{
	if ((self = [super initWithShape:[self boardMapping:specialBoardTypeInput] inWorld:world]))
	{
        specialBoardType_Object=specialBoardTypeInput;
        // set the parameters
        physicsBody->SetType(b2_dynamicBody);
        //控制讓他比較不容易旋轉
//        physicsBody->SetAngularDamping(0.9f);
        self.user_board_type_Object=user_board_type_input;

        physicsBody->SetBullet(true);
        
        dragEnabled=NO;
        temp_world=world;
        // set random starting point
        [self setuser_boardStartPosition];
        
        // enable handling touches
		[[CCDirector sharedDirector].touchDispatcher addStandardDelegate:self priority:4 ];
        
        // schedule updates
        self.dead=NO;
        [user_boardAdder setBoardExistance:user_board_type_input andBOOL:YES];
        

	}
	return self;
}

+(id) user_boardWithWorld:(b2World*)world user_board_type:(user_board_type)user_board_type_input andSpecialBoardType:(specialBoardType)specialBoardTypeInput
{
	return [[self alloc] initWithWorld:world user_board_type:user_board_type_input andSpecialBoardType:specialBoardTypeInput];
}

-(user_board_type) getuser_board_type
{
    return self.user_board_type_Object;
}


-(NSString*) boardMapping:(int)numberInput
{
    
    switch (numberInput) {
        case specialBoardTypeNormal:
            return @"user_board";
            break;
        case specialBoardTypeBigger:
            return @"user_boardBigger";
            break;
        case specialBoardTypeSmaller:
            return @"user_boardSmaller";
            break;
        case specialBoardTypeFreezed:
            return @"user_boardFreezed";
            break;
        default:
            return @"nothing";
            break;
    }
}



-(void) cleanup
{
	[super cleanup];
    [self unscheduleAllSelectors];
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

-(void) setuser_boardStartPosition
{
    // set the user_board's position
    //    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    //使用者的板子
    CGPoint startPos=CGPointMake(screenSize.width/2, screenSize.height*3/10);
    //如果是敵人的話
    if(self.user_board_type_Object!=user_board_type_player){
        startPos = CGPointMake(screenSize.width/2, screenSize.height*7/10);
    }
    
    
    physicsBody->SetTransform([Helper toMeters:startPos], 0.0f);
    physicsBody->SetLinearVelocity(b2Vec2_zero);
    physicsBody->SetAngularVelocity(0.0f);
}

-(void) updateLocationOfBoard:(ccTime)delta
{
    
    double nowTraveldDistance=[Helper distanceBetweenPoints:previousTouchLocation between:[Helper toPixels:physicsBody->GetPosition()]];
    
    if(shouldTraveledDistance<=nowTraveldDistance){
        physicsBody->SetTransform([Helper toMeters:previousTouchLocation], 0);
    }
    
    CGPoint differenceTouchLocation=[Helper subtract:currentTouchLocation of:previousTouchLocation];
    
    CGPoint velocity_temp=[Helper divide:differenceTouchLocation by:0.016];

    
    
    shouldTraveledDistance=[Helper distanceBetweenPoints:previousTouchLocation between:currentTouchLocation];
    
    physicsBody->SetLinearVelocity([Helper toMeters:velocity_temp]);    
    previousTouchLocation=currentTouchLocation;

    
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!dragEnabled&&!self.dead){
        NSSet *allTouches = touches;
        
        //檢查這個地方有沒有這個物體存在
        for (UITouch* touch in allTouches)
        {
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            if(
               (([Helper locationFromTouch:touch].y<=screenSize.height/2)&&(self.user_board_type_Object==user_board_type_player)
                &&([Helper locationFromTouch:touch].x>0))
                ||
               (([Helper locationFromTouch:touch].y>screenSize.height/2)&&(self.user_board_type_Object==user_board_type_enemy)
                &&([Helper locationFromTouch:touch].x>0))
               )
            {
                
                dragEnabled=YES;
                
                currentTouchLocation=[Helper locationFromTouch:touch];
                physicsBody->SetTransform([Helper toMeters:currentTouchLocation], 0);
                
                previousTouchLocation=currentTouchLocation;
                
                [self schedule: @selector(updateLocationOfBoard:) interval:0.016];
            
            }
            else{
                break;
            }
            
        }//這邊還沒寫敵人的情況

    
    }
}
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    

    if(dragEnabled&&!self.dead){
        NSSet *allTouches = [event allTouches];
        double smallestDistance=9999;
        CGPoint nearsetTouch;
        //檢查這個地方有沒有這個物體存在
        for (UITouch* touch in allTouches)
        {
            
            double tempDistance=[Helper distanceBetweenPoints:previousTouchLocation between:[Helper locationFromTouch:touch]];
            if(smallestDistance>tempDistance){
                smallestDistance=tempDistance;
                nearsetTouch=[Helper locationFromTouch:touch];
            }
        }
        
        currentTouchLocation=nearsetTouch;

//                physicsBody->SetTransform([Helper toMeters:[Helper locationFromTouch:touch]], 0.0f);
   
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(dragEnabled&&!self.dead){
        NSSet *allTouches = touches;
        for (UITouch* touch in allTouches)
        {
            double tempDistance=[Helper distanceBetweenPoints:previousTouchLocation between:[Helper locationFromTouch:touch]];
            
            if(tempDistance<200){
                dragEnabled=NO;
                physicsBody->SetLinearVelocity([Helper toMeters:[Helper makeIdentity]]);
                physicsBody->SetTransform([Helper toMeters:[Helper locationFromTouch:touch]], 0.0f);
                [self unschedule: @selector(updateLocationOfBoard:)];
                //基本上physicsBody只吃Meter，所以要給他的都要通過變成meter

                break;

            }
        }

    }
}

-(void) playSoundWithBall
{
//    NSLog(@"被叫到！");
	[[SimpleAudioEngine sharedEngine] playEffect:@"ballHit2.wav"];
}
-(void) playSoundWithTablePart
{
//    NSLog(@"被叫到！");
	[[SimpleAudioEngine sharedEngine] playEffect:@"hitSide.wav"];
}


-(void) endContactWithBall:(Contact*)contact
{

    CGPoint relativeContactPoint=[contact getrelativeConatactPoint];
    CGPoint tempPosition=[Helper toPixels:physicsBody->GetPosition()];
    CGPoint absoluteContactPoint=[Helper add:relativeContactPoint to:tempPosition];
    [ParticleEffectAdder addEffect:ballEffectTypeBall2Board andPosition:absoluteContactPoint];

	[self playSoundWithBall];
}

-(void) endContactWithuser_board:(Contact*)contact
{
    CGPoint relativeContactPoint=[contact getrelativeConatactPoint];
    CGPoint tempPosition=[Helper toPixels:physicsBody->GetPosition()];
    CGPoint absoluteContactPoint=[Helper add:relativeContactPoint to:tempPosition];
    [ParticleEffectAdder addEffect:ballEffectTypeBoard2Board andPosition:absoluteContactPoint];
	[self playSoundWithBall];
}

-(void) endContactWithTablePart:(Contact*)contact
{
	[self playSoundWithTablePart];
}

-(void) setPositionFromOutside:(b2Vec2)positionInput
{
    //試試看
    
    if(specialBoardType_Object!=specialBoardTypeFreezed){//凍結的時候這幾行就不執行，他就不能動了
        currentTouchLocation=[Helper toPixels:positionInput];
        previousTouchLocation=currentTouchLocation;
        [self schedule: @selector(updateLocationOfBoard:) interval:0.016];
        dragEnabled=NO;
    }else{
        dragEnabled=YES;
    }
    
    
    physicsBody->SetTransform(positionInput, 0);
    

    //如果是special的板子，要設一個變回來的TTL
    if(specialBoardType_Object!=specialBoardTypeNormal){
        toNormalTTL=5;
        [self schedule: @selector(TTLcountDown:) interval:1];
    }
    
}

-(b2Vec2) getPosition
{
    return physicsBody->GetPosition();
}

-(void) TTLcountDown:(ccTime)delta
{
    if(toNormalTTL>0){
        toNormalTTL--;
    }else{
        
        [user_boardAdder boardBiggerSmaller:self.user_board_type_Object andSpecialBoardType:specialBoardTypeNormal];
        
    }
        
}

-(void)user_boardDisabler//把板子丟出場外
{

//    [self unschedule: @selector(updateLocationOfBoard:)];
    [self unscheduleAllSelectors];
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    [self schedule: @selector(user_boardDisablerKick:)];
}

-(void) user_boardDisablerKick:(ccTime)delta//一直把她往外丟
{
    
    physicsBody->SetTransform([Helper toMeters:[Helper makeWithX:-500 Y:800]], 0);
    physicsBody->SetLinearVelocity([Helper toMeters:[Helper makeWithX:0 Y:0]]);
    
}
-(void)setDragEnable
{
    dragEnabled=YES;
}

@end
