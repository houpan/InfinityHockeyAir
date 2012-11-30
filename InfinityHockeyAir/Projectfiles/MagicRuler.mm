//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "MagicRuler.h"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import "ItemAdder.h"
#import "ParticleEffectAdder.h"

static MagicRuler* sharedMagicRulerInstance=nil;
@implementation MagicRuler




-(id) initWithSpriteU:(CCSprite*)spriteInput
{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    sharedSprite=spriteInput;
    
    
    //上面的個位數
    CCSprite *upperRuler = [CCSprite spriteWithSpriteFrameName:@"magic2"];
    upperRuler.position = ccp(screenSize.width, 0);
    upperRuler.anchorPoint=ccp(1,0);
    [sharedSprite addChild:upperRuler z:0 tag:RulerTypeUpper];
    
    CCSprite *lowerRuler = [CCSprite spriteWithSpriteFrameName:@"magic2"];
    lowerRuler.position = ccp(0, screenSize.height);
    lowerRuler.rotation=180;
    lowerRuler.opacity=80;//透明度從0~100
    lowerRuler.anchorPoint=ccp(1,0);
    [sharedSprite addChild:lowerRuler z:0 tag:RulerTypeLower];
    
    
    
    sharedMagicRulerInstance=self;
    
    userMagic=2;
    enemyMagic=2;
    
    return self;
}
//傳進來的時候不能access變數，所以要另外再init一次
+(id) MagicRulerWith:(CCSprite*)spriteInput
{
	return [[self alloc] initWithSpriteU:spriteInput];
}

+(MagicRuler*) sharedMagicRuler
{
    return sharedMagicRulerInstance;
}




-(NSString*) magicMapping:(int)numberInput
{
    switch (numberInput) {
        case 0:
            return @"nothing";
            break;
        case 1:
            return @"magic1";
            break;
        case 2:
            return @"magic2";
            break;
        case 3:
            return @"magic3";
            break;
        case 4:
            return @"magic4";
            break;
        case 5:
            return @"magic5";
            break;
        case 6:
            return @"magic6";
            break;            
        default:
            return @"";
            break;
    }

}

+(void) magicIncrementFromOutside:(user_board_type)caller andNumber:(int)numberInput
{
    [sharedMagicRulerInstance magicIncrement:caller andNumber:numberInput];
}


-(void) magicIncrement:(user_board_type)caller andNumber:(int)numberInput
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if(caller==user_board_type_player){
        userMagic+=numberInput;
        if(userMagic>=7){
            userMagic-=7;
            //之後應該是改成攻擊性隨機

            [ItemAdder addItemFromOutside:user_board_type_player andType:adRandom];


            CGPoint effectPosition=ccp(screenSize.width*9/10,screenSize.height*2/5);
            [ParticleEffectAdder addEffect:ballEffectTypeMagicRuler andPosition:effectPosition];
        }

    }else{
        enemyMagic+=numberInput;
        if(enemyMagic>=7){
            enemyMagic-=7;
            [ItemAdder addItemFromOutside:user_board_type_enemy andType:adRandom];
            CGPoint effectPosition=ccp(screenSize.width*1/10,screenSize.height*3/5);
            [ParticleEffectAdder addEffect:ballEffectTypeMagicRuler andPosition:effectPosition];

        }
    }
    
    
    if(caller==user_board_type_player){
        [sharedSprite removeChildByTag:RulerTypeLower cleanup:YES];
        CCSprite *newRuler = [CCSprite spriteWithSpriteFrameName:[self magicMapping:userMagic]];
        newRuler.position = ccp(screenSize.width, 0);
        newRuler.anchorPoint=ccp(1,0);
        [sharedSprite addChild:newRuler z:0 tag:RulerTypeUpper];

    
    }else{
        [sharedSprite removeChildByTag:RulerTypeUpper cleanup:YES];
        CCSprite *newRuler = [CCSprite spriteWithSpriteFrameName:[self magicMapping:enemyMagic]];
        newRuler.position = ccp(0, screenSize.height);
        newRuler.rotation=180;
        newRuler.opacity=80;//透明度從0~100
        newRuler.anchorPoint=ccp(1,0);
        [sharedSprite addChild:newRuler z:0 tag:RulerTypeLower];
        
    }

    

    
    


}
@end