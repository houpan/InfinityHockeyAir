//
//  Items.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Items.h"
#import "SimpleAudioEngine.h"
#import "ContactListener.h"
#import "ScoreBoard.h"
#import "MagicRuler.h"
#import "ItemAdder.h"
#import "Helper.h"
#import "ParticleEffectAdder.h"

@implementation Items
-(id) initWithWorld:(b2World*)world andCaller:(user_board_type)caller andNumber:(ItemType)numberInput
{
    randomSelectedType=randomDefault;
	if ((self = [super initWithShape:[self itemMapping:numberInput] inWorld:world]))
	{
        
        belong=caller;
        if(randomSelectedType!=randomDefault){//如果是random的情況
            instanceItemType=randomSelectedType;
        }else{
            instanceItemType=numberInput;//一般的情況
        }
        
        timeToLive=5;
        
        // set the parameters
        physicsBody->SetType(b2_dynamicBody);
        
        //控制讓他比較不容易旋轉
        physicsBody->SetAngularDamping(0.9f);

        physicsBody->SetBullet(true);
        // set random starting point
        
        [self setItemsStartPosition:[self positionDecide:caller]];

		[self schedule:@selector(TTLcountDown:) interval:1];
	}
	return self;
}

+(id) ItemsWithWorld:(b2World*)world andCaller:(user_board_type)caller andNumber:(ItemType)numberInput
{
	return [[self alloc] initWithWorld:world andCaller:caller andNumber:numberInput];
}

-(void) cleanup
{
	[super cleanup];
    [self unscheduleAllSelectors];
}



-(CGPoint)positionDecide:(user_board_type)user_board_type_input
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    switch (user_board_type_input) {
        case user_board_type_player:
            return CGPointMake(screenSize.width*1/4, screenSize.width*3/10);
            break;
        case user_board_type_enemy:
            return CGPointMake(screenSize.width*3/4, screenSize.width*7/10);
            break;
        case user_board_type_nobody:
            return CGPointMake(screenSize.width*0.8*CCRANDOM_0_1(), screenSize.height*0.8*CCRANDOM_0_1());
            break;
        default:
            break;
    }
}

-(NSString*) itemMapping:(int)numberInput
{
    
    int randomOffset=0;
    switch (numberInput) {
        case itemBallFaster:
            return @"itemBallFaster";
            break;
        case itemBallSmaller:
            return @"itemBallSmaller";
            break;
        case itemBallSucked:
            return @"itemBallSucked";
            break;
        case itemBoardBigger:
            return @"itemBoardBigger";
            break;
        case itemBoardSmaller:
            return @"itemBoardSmaller";
            break;
        case itemFireBall:
            return @"itemFireBall";
            break;
        case itemFreezeBoard:
            return @"itemFreezeBoard";
            break;
        case itemSplit2:
            return @"itemSplit2";
            break;
        case itemSplit10:
            return @"itemSplit10";
            break;
        case itemTableDissapear:
            return @"itemTableDissapear";
            break;
        case itemTableSmaller:
            return @"itemTableSmaller";
            break;
        case itemTableWider:
            return @"itemTableWider";
            break;
        case itemThunder:
            return @"itemThunder";
            break;
            
            
        case adRandom:
            randomOffset = CCRANDOM_0_1() * adNumber;
            randomSelectedType=(ItemType)(itemBallSucked+randomOffset);
            return [self itemMapping:itemBallSucked+randomOffset];
            break;
        case environmentalRandom:
            randomOffset = CCRANDOM_0_1() * environmentalNumber;
            randomSelectedType=(ItemType)(itemThunder+randomOffset);
            return [self itemMapping:itemThunder+randomOffset];
            break;
            
        default:
            return @" ";
            break;
    }
    
}




-(void) setItemsStartPosition:(CGPoint)ItemsPosition_input
{
    // set the Items's position
//    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    
    physicsBody->SetTransform([Helper toMeters:ItemsPosition_input], 0.0f);
    physicsBody->SetLinearVelocity(b2Vec2_zero);
    physicsBody->SetAngularVelocity(0.0f);
}


//把TTL -1，直到死掉為止，一秒一次
-(void) TTLcountDown:(ccTime)delta
{
    timeToLive--;
}


-(void) playSoundWithItems
{

	[[SimpleAudioEngine sharedEngine] playEffect:@"itemTouched.wav"];
}


-(void) endContactWithuser_board:(Contact*)contact
{
    //使用！
    
    user_board* tempBoard=(user_board*)[contact getObjectB];
    NSLog(@"碰，%d",tempBoard.dead);
    if(([tempBoard getuser_board_type]==belong
       ||
       belong==user_board_type_nobody)
        &&
       (tempBoard.dead!=YES)){
        [ItemAdder activateItem:belong andType:instanceItemType];
        NSLog(@"板子碰物體");
        [self playSoundWithItems];
        timeToLive=-1;
        b2Vec2 itemPosition=physicsBody->GetPosition();
        [ParticleEffectAdder addEffect:ballEffectTypeItemGet andPosition:[Helper toPixels:itemPosition]];
    }
    
}
-(int)getTTL
{
    return timeToLive;
}


@end
