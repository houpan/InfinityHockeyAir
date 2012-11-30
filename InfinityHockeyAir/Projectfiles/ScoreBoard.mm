//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "ScoreBoard.h"
#import "HockeyTableLayer.h"
#import "Constants.h"


static ScoreBoard* sharedScoreBoardInstance=nil;
@implementation ScoreBoard




-(id) initWithSpriteU:(CCSprite*)spriteInput
{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    sharedSprite=spriteInput;
    NSLog(@"YO!");
    //上面的個位數
    CCSprite *upperNumber = [CCSprite spriteWithSpriteFrameName:@"0u"];
    upperNumber.position = ccp(screenSize.width/2, screenSize.height*7/10);
    
    //anchor point的range只有從0~1之間，錯的話會判斷錯誤
    upperNumber.anchorPoint=ccp(0.5,0.5);
    [sharedSprite addChild:upperNumber z:0 tag:scoreUpper];

    //上面的十位數：剛開始是被隱藏起來的
    CCSprite *upperNumber10 = [CCSprite spriteWithSpriteFrameName:@"0u"];
    upperNumber10.position = ccp(-100,-100);
    upperNumber10.anchorPoint=ccp(0.5,0.5);
    [sharedSprite addChild:upperNumber10 z:0 tag:scoreUpper10];

    
    //下面的個位數
    CCSprite *lowerNumber = [CCSprite spriteWithSpriteFrameName:@"0d"];
    lowerNumber.position = ccp(screenSize.width/2, screenSize.height*3/10);
    lowerNumber.anchorPoint=ccp(0.5,0.5);
    [sharedSprite addChild:lowerNumber z:0 tag:scoreLower];

    
    //下面的十位數    
    CCSprite *lowerNumber10 = [CCSprite spriteWithSpriteFrameName:@"0u"];
    lowerNumber10.position = ccp(-100,-100);
    lowerNumber10.anchorPoint=ccp(0.5,0.5);
    [sharedSprite addChild:lowerNumber10 z:0 tag:scoreLower10];
    

    sharedScoreBoardInstance=self;
    
    userScore=0;
    enemyScore=0;
    return self;
}


//傳進來的時候不能access變數，所以要另外再init一次
+(id) ScoreBoardWith:(CCSprite*)spriteInput
{
	return [[self alloc] initWithSpriteU:spriteInput];
}

+(ScoreBoard*) sharedScoreBoard
{
    return sharedScoreBoardInstance;
}

-(NSString*) scoreMapping:(user_board_type)whosScore andNumber:(int)numberInput
{
    if(whosScore==user_board_type_player){
        switch (numberInput) {
            case 0:
                return @"0d";
                break;
            case 1:
                return @"1d";
                break;
            case 2:
                return @"2d";
                break;
            case 3:
                return @"3d";
                break;
            case 4:
                return @"4d";
                break;
            case 5:
                return @"5d";
                break;
            case 6:
                return @"6d";
                break;
            case 7:
                return @"7d";
                break;
            case 8:
                return @"8d";
                break;
            case 9:
                return @"9d";
                break;
                
            default:
                break;
        }
    }else{
        switch (numberInput) {
            case 0:
                return @"0u";
                break;
            case 1:
                return @"1u";
                break;
            case 2:
                return @"2u";
                break;
            case 3:
                return @"3u";
                break;
            case 4:
                return @"4u";
                break;
            case 5:
                return @"5u";
                break;
            case 6:
                return @"6u";
                break;
            case 7:
                return @"7u";
                break;
            case 8:
                return @"8u";
                break;
            case 9:
                return @"9u";
                break;
                
            default:
                return @"";
                break;
        }
    
    }


}

+(void) scoreIncrementFromOutside:(user_board_type)hitFrom
{
    [sharedScoreBoardInstance scoreIncrement:hitFrom];
}


-(void) scoreIncrement:(user_board_type)hitFrom
{
    double multiplier=0.1;
    double inverter=-1;//讓對面的顯示數字時，十位數跟個位數是正確的
    int scoreInput=0;
    
    
//    CCSprite *lowerNumber = [CCSprite spriteWithSpriteFrameName:@"0d"];
//    lowerNumber.position = ccp(screenSize.width/2, screenSize.height*3/10);
//    lowerNumber.anchorPoint=ccp(lowerNumber.scaleX/2,lowerNumber.scaleY/2);
//    [sharedSprite addChild:lowerNumber z:0 tag:scoreLower];
    
    
    if(hitFrom==user_board_type_player){
        [sharedSprite removeChildByTag:scoreLower cleanup:YES];
        [sharedSprite removeChildByTag:scoreLower10 cleanup:YES];
        userScore+=1;
        scoreInput=userScore;
    }else{
        [sharedSprite removeChildByTag:scoreUpper cleanup:YES];
        [sharedSprite removeChildByTag:scoreUpper10 cleanup:YES];
        enemyScore+=1;
        scoreInput=enemyScore;
    }
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *newNumber = [CCSprite spriteWithSpriteFrameName:[self scoreMapping:hitFrom andNumber:int(scoreInput%10)]];
    
    newNumber.anchorPoint=ccp(0.5,0.5);
    
    CCSprite *newNumber10 = [CCSprite spriteWithSpriteFrameName:[self scoreMapping:hitFrom andNumber:int(scoreInput/10)]];
    
    newNumber10.anchorPoint=ccp(0.5,0.5);

    
    if(hitFrom==user_board_type_player){
        inverter=1;
        multiplier*=3;
    }else{
        inverter=-1;
        multiplier*=7;
    }
    
    
    if(scoreInput<10){
        //為了完整性，還是要加上十位數，只是放再看不到的地方
        newNumber10.position = ccp(-100,-100);
        newNumber.position = ccp(screenSize.width/2.0, screenSize.height*multiplier);
    }else{
//        NSLog(@"[newNumber boundingBox].size.width/2.0)=%f",([newNumber boundingBox].size.width/2.0));
        newNumber.position = [Helper makeWithX:((float)(screenSize.width/2.0)+(float)([newNumber boundingBox].size.width/2.0)*inverter) Y:screenSize.height*multiplier];
        newNumber10.position = [Helper makeWithX:((float)(screenSize.width/2.0)-(float)([newNumber10 boundingBox].size.width/2.0)*inverter) Y:screenSize.height*multiplier];
    }

    if(hitFrom==user_board_type_player){
        [sharedSprite addChild:newNumber10 z:0 tag:scoreLower10];
        [sharedSprite addChild:newNumber z:0 tag:scoreLower];
    }else{
        [sharedSprite addChild:newNumber10 z:0 tag:scoreUpper10];
        [sharedSprite addChild:newNumber z:0 tag:scoreUpper];
    }
    

    
}
@end