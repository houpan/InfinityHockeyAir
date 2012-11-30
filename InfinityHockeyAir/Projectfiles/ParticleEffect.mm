//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "ParticleEffect.h"
#import "HockeyTableLayer.h"
#import "Constants.h"


static ParticleEffect* sharedParticleEffectInstance=nil;
@implementation ParticleEffect



-(id) initWithSprite:dSprite:(CCSprite*)spriteInput
{
    if ((self = [super init]))
	{
        sharedSprite=spriteInput;
        sharedParticleEffectInstance=self;
        [self schedule: @selector(TTLcountDownPE:) interval:0.5];
    }
    return self;
}

+(id) ParticleEffectWith:(b2World*)world andSprite:(CCSprite*)spriteInput
{
	return [[self alloc] initWithSprite:spriteInput];
}


+(void) addEffect:(ballEffectType)ballEffectTypeInput andPosition:(CGPoint)positionInput
{
    
    [sharedParticleEffectInstance addEffect_:ballEffectTypeInput andPosition:positionInput];
}

-(void) addEffect_:(ballEffectType)ballEffectTypeInput andPosition:(CGPoint)positionInput
{

    CCParticleSystem* system;
//    system=[CCParticleFlower node];
    system = [CCParticleSystemQuad particleWithFile:@"CA2.plist"];
    system.positionType = kCCPositionTypeFree;
//    system.texture = [CCSprite spriteWithSpriteFrameName:@"CA4Pic"];
//    CCSprite *temp=[CCSprite spriteWithSpriteFrameName:@"ballSmall"];
    
	system.position = positionInput;

    [arrayOfEffect addObject:system];
    [arrayOfEffectTTL addObject:[NSNumber numberWithInt:5]];
    [sharedSprite addChild:system];
}

-(void) TTLcountDownPE:(ccTime)delta
{
    NSUInteger i;

    NSUInteger originLength=[arrayOfEffect count];
    NSMutableArray *del_arrayOfEffectTTL=[[NSMutableArray alloc] init];
    NSMutableArray *del_arrayOfEffect=[[NSMutableArray alloc] init];
    for (i=0; i<originLength; i++) {
        if([[arrayOfEffectTTL objectAtIndex:i] intValue]>0)
        {//如果TTL大於零的話那就減一
            NSLog(@"現在的TTL是:%d",[[arrayOfEffectTTL objectAtIndex:i] intValue]);
            [arrayOfEffectTTL addObject:[NSNumber numberWithInt:([[arrayOfEffectTTL objectAtIndex:i] intValue]-1)]];
            [arrayOfEffect addObject:[arrayOfEffect objectAtIndex:i]];
            [del_arrayOfEffectTTL addObject:[arrayOfEffectTTL objectAtIndex:i]];
            [del_arrayOfEffect addObject:[arrayOfEffect objectAtIndex:i]];
        }else{
            [del_arrayOfEffectTTL addObject:[arrayOfEffectTTL objectAtIndex:i]];
            [del_arrayOfEffect addObject:[arrayOfEffect objectAtIndex:i]];
            [sharedSprite removeChild:[arrayOfEffect objectAtIndex:i] cleanup:YES];
        }
    }
    if([del_arrayOfEffect count]!=0){
        [arrayOfEffectTTL removeObjectsInArray:del_arrayOfEffectTTL];
        [arrayOfEffect removeObjectsInArray:del_arrayOfEffect];
    }

    NSLog(@"呼叫!");
}

-(void) cleanup
{
	[super cleanup];
    [self unscheduleAllSelectors];
}



@end

