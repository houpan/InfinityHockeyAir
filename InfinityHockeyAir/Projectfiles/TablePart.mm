//
//  Bumper.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "TablePart.h"
#import "Helper.h"

@implementation TablePart

-(id) initWithWorld:(b2World*)world position:(CGPoint)pos name:(NSString*)name andSpecialType:(SpecialTablePartsType)specialTypeInput
{
    switch (specialTypeInput){//之前沒處理好。總之這邊就是用傳進來是上面還是下面，並且配合後面specialType的資訊做事
        case SpecialTablePartsTypeNormal:
            break;
        case SpecialTablePartsTypeDissapear:
            if([name isEqualToString:@"boardUpper"])
            {
                name=@"boardUpperDissapear";
            }
            else{
                name=@"boardLowerDissapear";
            }
            break;
        case SpecialTablePartsTypeSmaller:
            if([name isEqualToString:@"boardUpper"])
            {
                name=@"boardUpperSmaller";
            }
            else{
                name=@"boardLowerSmaller";
            }
            break;
        case SpecialTablePartsTypeWider:
            if([name isEqualToString:@"boardUpper"])
            {
                name=@"boardUpperWider";
            }
            else{
                name=@"boardLowerWider";
            }
            break;
            
    }
	if ((self = [super initWithShape:name inWorld:world]))
	{
        // set the body position
        physicsBody->SetTransform([Helper toMeters:pos], 0.0f);

        // make the body static
        physicsBody->SetType(b2_staticBody);
        
        SpecialTablePartsType_object=specialTypeInput;
        
        if(SpecialTablePartsType_object==SpecialTablePartsTypeSmaller){
            smallerTTL=5;
        }else{
            smallerTTL=-1;
        }
        
        if(SpecialTablePartsType_object==SpecialTablePartsTypeWider){
            widerTTL=5;
        }else{
            widerTTL=-1;
        }
        if(SpecialTablePartsType_object==SpecialTablePartsTypeDissapear){
            dissapearTTL=5;
        }else{
            dissapearTTL=-1;
        }
        
        
		[self schedule:@selector(TTLcountDown:) interval:1];
        
	}
	return self;
}

+(id) tablePartInWorld:(b2World*)world position:(CGPoint)pos name:(NSString*)name andSpecialType:(SpecialTablePartsType)specialTypeInput
{
	return [[self alloc] initWithWorld:world position:pos name:name andSpecialType:specialTypeInput];
}

-(void)TTLcountDown:(ccTime)delta
{
    if(smallerTTL>0)
    {
        smallerTTL--;
    }
    
    if(widerTTL>0)
    {
        widerTTL--;
    }
    if(dissapearTTL>0)
    {
        dissapearTTL--;
    }
}



-(int) getSpecialTTL:(SpecialTablePartsType)specialTTLType
{
    switch (specialTTLType) {
        case SpecialTablePartsTypeSmaller:
            return smallerTTL;
            break;
        case SpecialTablePartsTypeWider:
            return widerTTL;
            break;
        case SpecialTablePartsTypeDissapear:
            return dissapearTTL;
            break;
        default:
            return -1;
            break;
    }
}
-(SpecialTablePartsType)getSpecialType
{
    return SpecialTablePartsType_object;
}
@end
