
#import "user_boardAdder.h"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import "ParticleEffectAdder.h"


static user_boardAdder* shareduser_boardAdderInstance=nil;
@implementation user_boardAdder



-(id) initWithWorld:(b2World*)worldInput andSprite:(CCSpriteBatchNode*)spriteInput
{
    if ((self = [super initWithShape:@"nothing" inWorld:worldInput])){
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        originuser_boardPosition=[Helper makeWithX:screenSize.width/2 Y:screenSize.height/2];
        sharedWorld=worldInput;
        sharedSprite=spriteInput;
        shareduser_boardAdderInstance=self;
        
        delay_user_boardTypeInput=[[NSMutableArray alloc] init];
        delay_newuser_board=[[NSMutableArray alloc] init];
        user_boardToKill=[[NSMutableArray alloc] init];
        user_boardToAdd=[[NSMutableArray alloc] init];
        [self schedule: @selector(user_boardKiller:) interval:0.2 ];
        return self;
    }
}


+(id) user_boardAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput
{
	return [[self alloc] initWithWorld:world andSprite:spriteInput];
}


+(void) adduser_boardFromOutside:(user_board_type)user_boardTypeInput andSpecialBoardType:(specialBoardType)specialBoardTypeInput
{
    [shareduser_boardAdderInstance adduser_board:user_boardTypeInput andSpecialBoardType:specialBoardTypeInput];
}

-(void) adduser_board:(user_board_type)user_boardTypeInput andSpecialBoardType:(specialBoardType)specialBoardTypeInput
{

    user_board* newuser_board=[user_board user_boardWithWorld:sharedWorld user_board_type:user_boardTypeInput andSpecialBoardType:specialBoardTypeInput];
    [sharedSprite  addChild:newuser_board z:2 tag:user_boardTypeInput];
}

+(void) setBoardExistance:(user_board_type)user_boar_type_input_ andBOOL:(BOOL)BOOL_
{
    
    switch (user_boar_type_input_) {
        case user_board_type_enemy:
            shareduser_boardAdderInstance.user_board_enemyExist=BOOL_;
            break;
        case user_board_type_player:
            shareduser_boardAdderInstance.user_board_playerExist=BOOL_;
        default:
            break;
    }
}


+(void) boardBiggerSmaller:(user_board_type)user_boardTypeInput andSpecialBoardType:(specialBoardType)specialBoardTypeInput
{
    [shareduser_boardAdderInstance boardBiggerSmallerI:user_boardTypeInput andSpecialBoardType:specialBoardTypeInput];
}
-(void) boardBiggerSmallerI:(user_board_type)user_boardTypeInput andSpecialBoardType:(specialBoardType)specialBoardTypeInput
{
    
    
    transmit_user_boardTypeInput=user_boardTypeInput;
    transmit_specialBoardTypeInput=specialBoardTypeInput;

    if(transmit_specialBoardTypeInput==specialBoardTypeFreezed||transmit_specialBoardTypeInput==specialBoardTypeSmaller){
        transmit_user_boardTypeInput=[self invertBoardType:transmit_user_boardTypeInput];
    }
    
    user_board* temp=(user_board*)[sharedSprite getChildByTag:transmit_user_boardTypeInput];
    if([user_boardToKill indexOfObject:temp] == NSNotFound){
        NSLog(@"塞進去");
        [user_boardToKill addObject:temp];
    }
    
}


-(void)user_boardKiller:(ccTime)delta
{//等一秒之後殺掉所有該殺的球，會用這個作法是，如果球的碰撞，是由於remove child才發生的，那就會碰撞失效就當機，
    //所以先把要殺的球丟到場外，等到碰撞結束，一秒鐘後再把它拔掉
    
    
    
    int length=[user_boardToKill count];
//    NSLog(@"要殺的長度:%d",length);
    if(length!=0){
        int i;
        for(i=length-1;i>-1;i--){
            user_board *temp=[user_boardToKill objectAtIndex:i];
            if([temp parent]==sharedSprite)
            {
//                NSLog(@"還在哦，殺");
                
                
                NSLog(@"變大被呼叫");

                
                b2Vec2 tempPosition=[temp getPosition];
                [temp user_boardDisabler];
                temp.dead=YES;
                if([user_boardToKill indexOfObject:temp] == NSNotFound){
                    NSLog(@"塞進去");
                    [user_boardToKill addObject:temp];
                }
                
                
                
                
                
                [sharedSprite removeChild:temp cleanup:YES];
                [user_boardAdder setBoardExistance:temp.user_board_type_Object andBOOL:NO];
                
                
                if((!shareduser_boardAdderInstance.user_board_enemyExist&&transmit_user_boardTypeInput==user_board_type_enemy)
                   ||
                   (!shareduser_boardAdderInstance.user_board_playerExist&&transmit_user_boardTypeInput==user_board_type_player)){
                    
                    user_board* newuser_board=[user_board user_boardWithWorld:sharedWorld user_board_type:transmit_user_boardTypeInput andSpecialBoardType:transmit_specialBoardTypeInput];
                    [newuser_board setPositionFromOutside:tempPosition];
                    [newuser_board setDragEnable];
                    [sharedSprite addChild:newuser_board z:2 tag:transmit_user_boardTypeInput];
                    [user_boardAdder setBoardExistance:temp.user_board_type_Object andBOOL:YES];
                    [ParticleEffectAdder addEffectBall:ballEffectTypeuser_boardChange andBall:newuser_board andTTLtime:TTLtimeuser_boardChange];
                    NSLog(@"US:%d,ENBOOL:%d",temp.user_board_type_Object,shareduser_boardAdderInstance.user_board_playerExist);
                }
                
            }else{
//                NSLog(@"真的不見了");
                [user_boardToKill removeObjectAtIndex:i];
            }
        }
    }

    
//    NSUInteger i;
//    if([user_boardToKill count]!=0){
//        user_board* balltemp =[user_boardToKill objectAtIndex:0];
//        NSLog(@"殺A");
//        [sharedSprite removeChild:balltemp cleanup:YES];
//        [user_boardToKill removeObjectAtIndex:0];
//    }
}

-(user_board_type)invertBoardType:(user_board_type)user_boardTypeInput
{
    if (user_boardTypeInput==user_board_type_player) {
        return user_board_type_enemy;
    }else{
        return user_board_type_player;
    }
}

@end