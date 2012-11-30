//
//  Ball.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Ball.h"
#import "SimpleAudioEngine.h"
#import "ContactListener.h"
#import "ScoreBoard.h"
#import "MagicRuler.h"
#import "ItemAdder.h"
#import "ParticleEffectAdder.h"
//關於import，最好在mm檔裡面做，這樣比較可以避免循環import的問題


@implementation Ball
-(id) initWithWorld:(b2World*)world andBallType:(ballType)ballTypeInput andBallPosition:(CGPoint)ballPosition_input
{
	if ((self = [super initWithShape:[self ballTypeMapping:ballTypeInput] inWorld:world]))
	{
    NSLog(@"whay?!!");
        selfBallType=ballTypeInput;
        // set the parameters
        physicsBody->SetType(b2_dynamicBody);
        
        //控制讓他比較不容易旋轉
//        physicsBody->SetAngularDamping(0.9f);

        physicsBody->SetBullet(true);
        // set random starting point
        [self setBallStartPosition:ballPosition_input];

        //各個屬性都要有TTL(除了normal之外)
        
        
        if(ballTypeInput==ballTypeSmall){
            smallerTTL=TTLtimeSmaller;
        }else{
            smallerTTL=-1;
        }
        
        if(ballTypeInput==ballTypeFire){
            fireTTL=TTLtimeFire;
        }else{
            fireTTL=-1;
        }
        
        fasterTTL=-1;

        suckedTTL=-1;
        fasterActivated=NO;
        isCloned=NO;
        isClonedGetIn=NO;
        suckedActivated=NO;
        
        ballDead=NO;
        // schedule updates
		[self scheduleUpdate];
		[self schedule:@selector(TTLcountDown:) interval:1];
	}
	return self;
}

+(id) ballWithWorld:(b2World*)world andBallType:(ballType)ballTypeInput andBallPosition:(CGPoint)ballPosition_input
{
	return [[self alloc] initWithWorld:world andBallType:ballTypeInput andBallPosition:ballPosition_input];
}

-(void)ballFasterActivate:(fasterType)fasterTypeInput
{
    fasterActivated=YES;
    if(fasterTypeInput==fasterTypeItem){
        fasterTTL=TTLtimefasterLevel1;
        physicsBody->SetLinearVelocity([Helper speedBooster:physicsBody->GetLinearVelocity() andMultiplier:50]);
    }else{
        fasterTTL=TTLtimefasterLevel2;
        physicsBody->SetLinearVelocity([Helper speedBooster:physicsBody->GetLinearVelocity() andMultiplier:5]);
    }

}

//要顯示的骨架！
-(NSString*) ballTypeMapping:(ballType)ballTypeInput
{
    switch (ballTypeInput) {
        case ballTypeNormal:
            return @"ball";
            break;
        case ballTypeSmall:
            return @"ballSmall";
            break;
        case ballTypeFire:
            return @"ballFire";
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
}

-(void) setBallStartPosition:(CGPoint)ballPosition_input
{
    // set the ball's position
//    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    CGPoint startPos = ballPosition_input;
    
    physicsBody->SetTransform([Helper toMeters:startPos], 0.0f);
    physicsBody->SetLinearVelocity(b2Vec2_zero);
    physicsBody->SetAngularVelocity(0.0f);
}

-(void) TTLcountDown:(ccTime)delta
{
    if(smallerTTL>0)
    {
        smallerTTL--;
    }
    if(fasterTTL>0&&fasterActivated==YES){
        fasterTTL--;
    }else if(fasterTTL<=0&&fasterActivated==YES){
        //自己把加速關掉
        fasterActivated=NO;
    }
    if(fireTTL>0){
        fireTTL--;
    }
    if(suckedTTL>0){
        suckedTTL--;
    }
}

-(void) update:(ccTime)delta
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if([Helper toPixels:physicsBody->GetPosition()].y>screenSize.height){
        [ScoreBoard scoreIncrementFromOutside:user_board_type_player];
        if(!isCloned){//如果是clone人就不能加分，這樣人就不會無限增長了
            [MagicRuler magicIncrementFromOutside:user_board_type_player andNumber:1];
            [MagicRuler magicIncrementFromOutside:user_board_type_enemy andNumber:2];
        }


        [self ballGetIn];
    }
    else if([Helper toPixels:physicsBody->GetPosition()].y<0){
        [ScoreBoard scoreIncrementFromOutside:user_board_type_enemy];
        if(!isCloned){//如果是clone人就不能加分，這樣人就不會無限增長了
            [MagicRuler magicIncrementFromOutside:user_board_type_player andNumber:2];
            [MagicRuler magicIncrementFromOutside:user_board_type_enemy andNumber:1];
        }

        [self ballGetIn];
    }

    
    
}
-(void) ballGetIn
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    [self playSoundGetScore];
    if(isCloned){//複製人只有被殺的命運，所以就把它發配邊疆
        isClonedGetIn=YES;
        physicsBody->SetTransform([Helper toMeters:[Helper makeWithX:-screenSize.width*2 Y:screenSize.height/2]], 0.0f);
    }else{
        physicsBody->SetTransform([Helper toMeters:[Helper makeWithX:screenSize.width/2 Y:screenSize.height/2]], 0.0f);
    }
        physicsBody->SetLinearVelocity(b2Vec2_zero);
}


-(void) playSoundWithBall
{

	[[SimpleAudioEngine sharedEngine] playEffect:@"ballHit2.wav"];
}

-(void) playSoundWithTablePart
{
    
	[[SimpleAudioEngine sharedEngine] playEffect:@"hitSide.wav"];
}

-(void) playSoundGetScore
{
    
	[[SimpleAudioEngine sharedEngine] playEffect:@"getIn.wav"];
}

-(void) endContactWithBall:(Contact*)contact
{
    if (!ballDead) {
        CGPoint relativeContactPoint=[contact getrelativeConatactPoint];
        CGPoint tempPosition=[Helper toPixels:physicsBody->GetPosition()];
        CGPoint absoluteContactPoint=[Helper add:relativeContactPoint to:tempPosition];
        [ParticleEffectAdder addEffect:ballEffectTypeBall2Ball andPosition:absoluteContactPoint];
        [self playSoundWithBall];
    }
}

-(void) endContactWithTablePart:(Contact*)contact
{
    CGPoint relativeContactPoint=[contact getrelativeConatactPoint];
    CGPoint tempPosition=[Helper toPixels:physicsBody->GetPosition()];
    CGPoint absoluteContactPoint=[Helper add:relativeContactPoint to:tempPosition];
    [ParticleEffectAdder addEffect:ballEffectTypeBall2table andPosition:absoluteContactPoint];
	[self playSoundWithTablePart];
}

-(ballType)getBallType{

    return selfBallType;
}
-(int)getTTL:(ballType)ballTypeInput
{
    switch(ballTypeInput){
        case ballTypeSmall:
            return smallerTTL;
            break;
        case ballTypeFire:
            return fireTTL;
            break;
        case ballTypeFaster_forTTL:
            return fasterTTL;
            break;
        case ballTypeSucked_forTTL:
            return suckedTTL;
            break;
        default:
            return -1;
            break;
    }
}

-(void)setVelocity:(b2Vec2)velocityInput
{
    physicsBody->SetLinearVelocity(velocityInput);

}
-(void)setIsCloned{
    isCloned=YES;
}
-(BOOL)checkCloneGetIn
{
    return isClonedGetIn;
}
-(BOOL)checkIsCloned{
    return isCloned;
}
-(void)ballSuckedActivate:(user_board_type)caller
{
    suckedTTL=TTLtimeSucked;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    //caller是發動攻擊的人，所以是另外一邊的人要受害
    

    if(caller==user_board_type_player){
        suckedDestination=[Helper toMeters:[Helper makeWithX:screenSize.width/2 Y:screenSize.height*5/4]];
    }else
    {
        suckedDestination=[Helper toMeters:[Helper makeWithX:screenSize.width/2 Y:0-screenSize.height*1/4]];
    }
    

    suckedActivated=YES;
    [self schedule:@selector(ballSuckedUpdater:) interval:0.16];
}

-(BOOL)checkSuckedActivated{
    return suckedActivated;
}

-(void)ballSuckedUpdater:(ccTime)delta
{
    b2Vec2 bodyToFingerDirection = suckedDestination - physicsBody->GetPosition();

    float distance = bodyToFingerDirection.Length();
    float distanceSquared = distance * distance;
    bodyToFingerDirection.Normalize();
    b2Vec2 force =((10*(distanceSquared))) * bodyToFingerDirection;
    physicsBody->ApplyForce(force, physicsBody->GetWorldCenter());

}

-(void)ballSuckedDeactivate
{
    suckedActivated=NO;
    [self unschedule:@selector(ballSuckedUpdater:)];
}


-(void)ballDisabler//把球丟出場外
{
    physicsBody->SetTransform([Helper toMeters:[Helper makeWithX:-1000 Y:0]], 0);
    physicsBody->SetLinearVelocity([Helper toMeters:[Helper makeWithX:0 Y:0]]);
    ballDead=YES;
}

@end
