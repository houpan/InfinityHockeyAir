//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "ParticleEffectAdder.h"
#import "Ball.h"


static ParticleEffectAdder* sharedParticleEffectAdderInstance=nil;
@implementation ParticleEffectAdder



-(id) initWithWorld:(b2World*)worldInput andSprite:(CCSprite*)spriteInput
{
    if ((self = [super init]))
	{
        sharedSprite=spriteInput;
        sharedParticleEffectAdderInstance=self;
        arrayOfEffect=[[NSMutableArray alloc]init];
        arrayOfEffectTTL=[[NSMutableArray alloc]init];
        arrayOfEffectBall=[[NSMutableArray alloc]init];
        arrayOfBall=[[NSMutableArray alloc]init];
        arrayOfuserboard=[[NSMutableArray alloc]init];
        aSecondRatio=0.2;
        aSecondMeter=0;
        nullBall=[BodySprite alloc];
        
        global_bodyInput=nil;
        global_objIdx =-1;
        
        [self schedule: @selector(TTLcountDownPE:) interval:aSecondRatio];
        [self schedule: @selector(ballRemoverSynchronizer:) interval:aSecondRatio];
        

        
//        [self schedule: @selector(TTLcountDownPEBall:) interval:0.3];
        
    }
    return self;
}

+(id) ParticleEffectAdderWith:(b2World*)world andSprite:(CCSprite*)spriteInput
{
	return [[self alloc] initWithWorld:world andSprite:spriteInput];
}

+(void) ballRemover:(BodySprite*)bodyInput//主要是因為如果板子自己在adder裡面死掉被remove的話
{                                           //arrayOfBall這個array裡面的pointer可能就dangling了
    [sharedParticleEffectAdderInstance ballRemover_:bodyInput];
}
-(void) ballRemover_:(BodySprite*)bodyInput
{
    global_bodyInput=bodyInput;
    global_objIdx = [arrayOfBall indexOfObject:bodyInput];
    NSLog(@"第一次查到的%d",global_objIdx);
    if(global_objIdx == NSNotFound){
        NSLog(@"但查不到..");
        global_bodyInput=nil;
        global_objIdx =-1;
    }
}

-(void) ballRemoverSynchronizer:(ccTime)delta
{
    if(global_objIdx!=-1){
        NSLog(@"有東西在裡面,array裡面有%d個",[arrayOfBall count]);

        global_objIdx=[arrayOfBall indexOfObject:global_bodyInput];
        if(global_objIdx != NSNotFound){
            NSLog(@"找到，在第%d個，殺",global_objIdx);
            NSLog(@"殺C");
            [sharedSprite removeChild:[arrayOfEffect objectAtIndex:global_objIdx] cleanup:YES];
            [arrayOfEffectBall removeObjectAtIndex:global_objIdx];
            [arrayOfBall removeObjectAtIndex:global_objIdx];
            [arrayOfEffect removeObjectAtIndex:global_objIdx];
            [arrayOfEffectTTL removeObjectAtIndex:global_objIdx];//TTL是看他活多久
        }else{
            global_bodyInput=nil;
            global_objIdx =-1;
        }
//        global_objIdx = [arrayOfBall indexOfObject:global_bodyInput];
//        NSLog(@"第二次查到的%d",global_objIdx);
    }
}

+(void) addEffectBall:(ballEffectType)ballEffectTypeInput andBall:(BodySprite*)BallInput andTTLtime:(TTLtime)TTLinput
{
    [sharedParticleEffectAdderInstance addEffectBall_:ballEffectTypeInput andBall:BallInput andTTLtime:TTLinput];
}

-(void) addEffectBall_:(ballEffectType)ballEffectTypeInput andBall:(BodySprite*)BallInput andTTLtime:(TTLtime)TTLinput
{
    
//    
//    arrayOfEffectBall=[[NSMutableArray alloc]init];
//    arrayOfBall=[[NSMutableArray alloc]init];
    
    CCParticleSystem* system;
    switch (ballEffectTypeInput) {
        case ballEffectTypeSmallBallSelf:
            system = [CCParticleSystemQuad particleWithFile:@"PEradical.plist"];
            break;
        case ballEffectTypeFireBallSelf:
            system = [CCParticleSystemQuad particleWithFile:@"PEfireBall2.plist"];
            break;
        case ballEffectTypeuser_boardChange:
            system = [CCParticleSystemQuad particleWithFile:@"PEexplode4.plist"];
//            system = [CCParticleSystemQuad particleWithFile:@"PEexplode4.plist"];
            break;
        default:
            break;
    }

    system.positionType = kCCPositionTypeFree;
	system.position = [BallInput getBodySpritePosition];

    NSUInteger objIdx = [arrayOfBall indexOfObject:BallInput];
    if(objIdx == NSNotFound) {
        [arrayOfEffectBall addObject:[NSNumber numberWithBool:YES]];
        [arrayOfBall addObject:BallInput];
        [arrayOfEffect addObject:system];
        [arrayOfEffectTTL addObject:[NSNumber numberWithInt:TTLinput+1]];//TTL是看他活多久
        [sharedSprite addChild:system];
    }else{
        [arrayOfEffectTTL replaceObjectAtIndex:objIdx withObject:[NSNumber numberWithInt:TTLinput+1]];//TTL是看他活多久
    }

    
    NSLog(@"第一次new球");
}
+(void) addEffect:(ballEffectType)ballEffectTypeInput andPosition:(CGPoint)positionInput
{

    [sharedParticleEffectAdderInstance addEffect_:ballEffectTypeInput andPosition:positionInput];
}



-(void) addEffect_:(ballEffectType)ballEffectTypeInput andPosition:(CGPoint)positionInput
{

    CCParticleSystem* system;
//    system=[CCParticleFlower node];
    int tempTTL=5;
    system.positionType = kCCPositionTypeFree;
    switch (ballEffectTypeInput) {
        case ballEffectTypeBall2Ball:
            system = [CCParticleSystemQuad particleWithFile:@"PEbump1.plist"];
            break;
        case ballEffectTypeBall2Board:
            system = [CCParticleSystemQuad particleWithFile:@"PEbump1.plist"];
            NSLog(@"單純球版碰newEfefct");
            tempTTL=0.5;
            break;
        case ballEffectTypeBall2table:
            system = [CCParticleSystemQuad particleWithFile:@"PEbump1.plist"];
            tempTTL=0.5;
            break;
        case ballEffectTypeMagicRuler:
            system = [CCParticleSystemQuad particleWithFile:@"PEmagic.plist"];
            break;
        case ballEffectTypeBoard2Board://板子變大的時候原版跟新版會碰撞兩次
            system = [CCParticleSystemQuad particleWithFile:@"PEbump2.plist"];
            tempTTL=0.5;
            break;
        case ballEffectTypeSuck:
            system = [CCParticleSystemQuad particleWithFile:@"PEsuck.plist"];
            tempTTL=TTLtimeSucked;
            break;
        case ballEffectTypeItemGet:
            system = [CCParticleSystemQuad particleWithFile:@"PEgetItem.plist"];
            break;
        case ballEffectTypeTableChange:
            system = [CCParticleSystemQuad particleWithFile:@"PEtablepart.plist"];
            break;
            
        default:
            break;
    }

//    system.texture = [CCSprite spriteWithSpriteFrameName:@"CA4Pic"];
//    CCSprite *temp=[CCSprite spriteWithSpriteFrameName:@"ballSmall"];
    
	system.position = positionInput;

    [arrayOfEffect addObject:system];
    [arrayOfEffectTTL addObject:[NSNumber numberWithInt:tempTTL]];//TTL是看他活多久
    
    [arrayOfEffectBall addObject:[NSNumber numberWithBool:NO]];//用來標示這個特效不用追蹤
    [arrayOfBall addObject:nullBall];//如果沒有球，就隨便放個東西進去

    [sharedSprite addChild:system];
//    NSLog(@"--newEfefct");
}

//
//-(void) TTLcountDownPEBall:(ccTime)delta
//{
//    NSUInteger i;
//    NSMutableArray *newArrayOfBall=[[NSMutableArray alloc] init];
//    NSMutableArray *newArrayOfEffectOfBall=[[NSMutableArray alloc] init];
//    NSLog(@"現在Ball有:%d",[arrayOfBall count]);
//    for (i=0; i<[arrayOfEffectBall count]; i++) {
//        CCParticleSystem* temp_particle=[arrayOfEffectBall objectAtIndex:i];
//        Ball* temp_ball=[arrayOfBall objectAtIndex:i];
//        temp_particle.position=[temp_ball getBodySpritePosition];
//        [newArrayOfBall addObject:temp_ball];
//        [newArrayOfEffectOfBall addObject:temp_particle];
//        
//        [arrayOfEffectBall replaceObjectAtIndex:i withObject:temp_particle];
//    }
//    
//    NSLog(@"呼叫2!");
//}


-(void) TTLcountDownPE:(ccTime)delta
{
    int aSecondToSubstract=0;
    aSecondMeter+=aSecondRatio;
    if(aSecondMeter>=1){
        aSecondMeter=0;
        aSecondToSubstract=1;
    }
    
    NSUInteger i;
    
    NSUInteger originLength=[arrayOfEffect count];
    NSMutableArray *new_arrayOfEffectTTL=[[NSMutableArray alloc] init];
    NSMutableArray *new_arrayOfEffect=[[NSMutableArray alloc] init];
    NSMutableArray *newArrayOfBall=[[NSMutableArray alloc] init];
    NSMutableArray *new_arrayOfEffectBall=[[NSMutableArray alloc] init];
    
    for (i=0; i<originLength; i++) {
        if([[arrayOfEffectTTL objectAtIndex:i] intValue]>0)
        {//如果TTL大於零的話那就減一
            //            NSLog(@"現在的TTL是:%d",[[arrayOfEffectTTL objectAtIndex:i] intValue]);
            [new_arrayOfEffectTTL addObject:[NSNumber numberWithInt:([[arrayOfEffectTTL objectAtIndex:i] intValue]-aSecondToSubstract)]];
            CCParticleSystem* temp_system=[arrayOfEffect objectAtIndex:i];
            BodySprite* temp_ball;

            if([[arrayOfEffectBall objectAtIndex:i] boolValue]){
                temp_ball=[arrayOfBall objectAtIndex:i];
                temp_system.position=[temp_ball getBodySpritePosition];
                [new_arrayOfEffectBall addObject:[NSNumber numberWithBool:YES]];
            }else{
                temp_ball=nullBall;
                [new_arrayOfEffectBall addObject:[NSNumber numberWithBool:NO]];
            }
            
            if([[arrayOfEffectTTL objectAtIndex:i] intValue]==1)//從某個threshold開始砍他的duration讓他自然死，CA2差不多兩秒就死了
            {
                temp_system.duration=-0.9f;
                temp_system.life=0.1f;
            }
            [new_arrayOfEffect addObject:temp_system];
            [newArrayOfBall addObject:temp_ball];//其實tempBall也沒做什麼大改變，只是為了讓順序對所以才重新創一個

        }else if([[arrayOfEffectTTL objectAtIndex:i] intValue]==0){
//            NSLog(@"殺B");
//            [sharedSprite removeChild:[arrayOfEffect objectAtIndex:i] cleanup:YES];
        }
        
        
    }
//    NSLog(@"四個:%d,%d,%d,%d",[new_arrayOfEffect count],[new_arrayOfEffectTTL count],[newArrayOfBall count],[new_arrayOfEffectBall count]);
    arrayOfEffect=new_arrayOfEffect;
    arrayOfEffectTTL=new_arrayOfEffectTTL;
    arrayOfBall=newArrayOfBall;
    arrayOfEffectBall=new_arrayOfEffectBall;




//    NSLog(@"呼叫!");
}

-(void) cleanup
{
	[super cleanup];
    [self unscheduleAllSelectors];
}



@end

