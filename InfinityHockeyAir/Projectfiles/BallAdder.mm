//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BallAdder.h"
#import "HockeyTableLayer.h"
#import "Constants.h"


static BallAdder* sharedBallAdderInstance=nil;
@implementation BallAdder


-(id) initWithWorld:(b2World*)worldInput andSprite:(CCSpriteBatchNode*)spriteInput
{
    if ((self = [super initWithShape:@"nothing" inWorld:worldInput]))
	{
        transmit_ballTypeInput=ballTypeNULL;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        originBallPosition=[Helper makeWithX:screenSize.width/2 Y:screenSize.height/2];
        sharedWorld=worldInput;
        sharedSprite=spriteInput;
        sharedBallAdderInstance=self;
        arrayOfBall=[[NSMutableArray alloc]init];
        ballToKill=[[NSMutableArray alloc]init];
        [self schedule: @selector(checkSpecialTTL:) interval:0.05 ];
        [self schedule: @selector(ballKiller:) interval:0.2 ];
        return self;
    }
}


+(id) BallAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput
{
	return [[self alloc] initWithWorld:world andSprite:spriteInput];
}

-(void)ballKiller:(ccTime)delta
{//等一秒之後殺掉所有該殺的球，會用這個作法是，如果球的碰撞，是由於remove child才發生的，那就會碰撞失效就當機，
    //所以先把要殺的球丟到場外，等到碰撞結束，一秒鐘後再把它拔掉

    if(transmit_ballTypeInput!=ballTypeNULL){
    
        TTLtime tempTTLtime;
        ballEffectType tempballEffect;
        switch (transmit_ballTypeInput){
            case ballTypeSmall:
                tempTTLtime=TTLtimeSmaller;
                tempballEffect=ballEffectTypeSmallBallSelf;
                break;
            case ballTypeFire:
                tempTTLtime=TTLtimeFire;
                tempballEffect=ballEffectTypeFireBallSelf;
                break;
            default:
                break;
        }
        
        b2Vec2 tempPosition;
        b2Vec2 tempVelocity;
        NSMutableArray *new_arrayOfBall=[[NSMutableArray alloc] init];
        for(Ball* ballFetched in arrayOfBall){
            tempPosition=ballFetched.physicsBody->GetPosition();
            tempVelocity=ballFetched.physicsBody->GetLinearVelocity();
            //**不同
            Ball* newBall=[Ball ballWithWorld:sharedWorld andBallType:transmit_ballTypeInput andBallPosition:[Helper toPixels:tempPosition]];
            //把速度設成跟原來一樣，這樣感覺會比較順
            [newBall setVelocity:tempVelocity];
            [new_arrayOfBall addObject:newBall];
            [ballFetched ballDisabler];
            [sharedSprite addChild:newBall z:1];
            
            if([ballFetched checkIsCloned])
            {
                [newBall setIsCloned];
            }
            //**不同
            if(transmit_ballTypeInput!=ballTypeNormal){
                [ParticleEffectAdder addEffectBall:tempballEffect andBall:newBall andTTLtime:tempTTLtime];
            }
            //在parent把這個body刪掉，系統應該就會自己管理他的記憶體了吧？吧？
            
            
            if([ballToKill indexOfObject:ballFetched]==NSNotFound){
                NSLog(@"++");
                [ballToKill addObject:ballFetched];
            }
            
            
            
        }
        arrayOfBall=[[NSMutableArray alloc] initWithArray:new_arrayOfBall];
        transmit_ballTypeInput=ballTypeNULL;
    }
    

//        int length=[ballToKill count];
//        NSLog(@"長度:%d",length);
//        if(length!=0){
//            int i;
//            for(i=length-1;i>-1;i--){
//                Ball *temp=[ballToKill objectAtIndex:i];
//                if([temp parent]==sharedSprite)
//                {
//                    NSLog(@"還在哦，殺");
//                    [sharedSprite removeChild:temp cleanup:YES];
//                }else{
//                    NSLog(@"真的不見了");
//                    [ballToKill removeObjectAtIndex:i];
//                }
//            }
//        }
//    }
    
    
    
    //
    int length=[ballToKill count];
    if(length!=0){
        int i;
        for(i=0;i<length;i++){
            Ball* ballTemp=[ballToKill objectAtIndex:i];
            [sharedSprite removeChild:ballTemp cleanup:YES];
        }
        for (i=0; i<length; i++) {
            [ballToKill removeObjectAtIndex:0];
        }
    }
}




-(void)checkSpecialTTL:(ccTime)delta
{
    
    for(Ball* ballFetched in arrayOfBall){
        if(([ballFetched getBallType]==ballTypeSmall&&[ballFetched getTTL:ballTypeSmall]<=0)||
        ([ballFetched getBallType]==ballTypeFire&&[ballFetched getTTL:ballTypeFire]<=0)){
            [self ballChangeAll:ballTypeNormal];
        }else if([ballFetched checkCloneGetIn]&&[ballFetched checkIsCloned]){
            CCLOG(@"移除！");
            [sharedSprite removeChild:ballFetched cleanup:YES];
            [arrayOfBall removeObject:ballFetched];
            break;
        }else if([ballFetched getTTL:ballTypeSucked_forTTL]<=0&&[ballFetched checkSuckedActivated]){
            [ballFetched ballSuckedDeactivate];
            break;
        }else if([ballFetched getBallType]==ballTypeNormal){
            continue;
        }
        //Faster全部都交給球自己處理，如果TTL過期就自己改回原來速度
    }

}

+(void) addBallFromOutside:(ballType)ballTypeInput
{
    [sharedBallAdderInstance addBall:ballTypeInput];

}

-(void) addBall:(ballType)ballTypeInput
{
    CGPoint ballPosition;
    switch (ballTypeInput) {
        case ballTypeNormal:
            ballPosition=originBallPosition;
            break;
            
        default:
            break;
    }
    
    Ball* newBall=[Ball ballWithWorld:sharedWorld andBallType:ballTypeInput andBallPosition:ballPosition];
    [arrayOfBall addObject:newBall];
    [sharedSprite addChild:newBall z:1];
}


+(void) ballMultiply:(int)numberInput
{
    [sharedBallAdderInstance ballMultiplyI:numberInput];
}


-(void) ballMultiplyI:(int)numberInput
{
    b2Vec2 tempPosition;
    ballType tempBallType;
    int i;
    if([arrayOfBall count]>=20){//如果炸裂就不讓他加了
        return;
    }
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    NSMutableArray *new_arrayOfBall=[[NSMutableArray alloc] init];
    for(Ball* ballFetched in arrayOfBall){
        tempBallType=[ballFetched getBallType];
        for(i=0;i<numberInput;i++){
            Ball* newBall=[Ball ballWithWorld:sharedWorld andBallType:tempBallType andBallPosition:[Helper makeWithX:(0.5+CCRANDOM_MINUS1_1()*0.3)*screenSize.width Y:(0.5+CCRANDOM_MINUS1_1()*0.3)*screenSize.height*0.8]];
            [newBall setIsCloned];
            [newBall setVelocity:b2Vec2_zero];
            [new_arrayOfBall addObject:newBall];
            
            TTLtime tempTTLtime;
            ballEffectType tempballEffect;
            switch (tempBallType){
                case ballTypeSmall:
                    tempTTLtime=TTLtimeSmaller;
                    tempballEffect=ballEffectTypeSmallBallSelf;
                    break;
                case ballTypeFire:
                    tempTTLtime=TTLtimeFire;
                    tempballEffect=ballEffectTypeFireBallSelf;
                    break;
                default:
                    break;
            }
            
            if(tempBallType!=ballTypeNormal){
//                [ParticleEffectAdder addEffectBall:tempballEffect andBall:newBall andTTLtime:tempTTLtime];
            }
            
            
            [sharedSprite addChild:newBall z:1];
            CCLOG(@"現在原array有%d個數，新array有%d個數",[arrayOfBall count],[new_arrayOfBall count]);
            if([arrayOfBall count]>=20){//如果炸裂就不讓他加了
                return;
            }
        }
        break;//這是個假for，其實只執行一次
    }
    
    [arrayOfBall addObjectsFromArray:new_arrayOfBall];
            CCLOG(@"現在原array有%d個數，新array有%d個數",[arrayOfBall count],[new_arrayOfBall count]);
}

+(void) ballFaster:(fasterType)fasterTypeInput
{
    [sharedBallAdderInstance ballFasterI:fasterTypeInput];
}

-(void) ballFasterI:(fasterType)fasterTypeInput
{
    for(Ball* ballFetched in arrayOfBall){
        [ballFetched ballFasterActivate:fasterTypeInput];
    }
}
+(void) ballSucked:(user_board_type)user_boardTypeInput
{
    [sharedBallAdderInstance ballSuckedI:user_boardTypeInput];
}
-(void)ballSuckedI:(user_board_type)user_boardTypeInput
{
    for(Ball* ballFetched in arrayOfBall){
        [ballFetched ballSuckedActivate:user_boardTypeInput];
    }
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if(user_boardTypeInput==user_board_type_player){
        [ParticleEffectAdder addEffect:ballEffectTypeSuck andPosition:ccp(screenSize.width/2, screenSize.height*9/8)];
    }else{
        [ParticleEffectAdder addEffect:ballEffectTypeSuck andPosition:ccp(screenSize.width/2, -screenSize.height*1/8)];
    }
}
+(void) ballSpecial:(ballType)ballTypeInput
{
    [sharedBallAdderInstance ballChangeAll:ballTypeInput];
}

-(void) ballChangeAll:(ballType)ballTypeInput
{
    
    transmit_ballTypeInput=ballTypeInput;
    
}
@end
