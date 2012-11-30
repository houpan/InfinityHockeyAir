//
//  Ball.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "MouseListener.h"


class QueryCallback : public b2QueryCallback
{
public:
    QueryCallback(const b2Vec2& point)
    {
        m_point = point;
        m_object = nil;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        if (fixture->IsSensor()) return true; //ignore sensors
        
        bool inside = fixture->TestPoint(m_point);
        if (inside)
        {
            // We are done, terminate the query.
            m_object = fixture->GetBody();
            return false;
        }
        
        // Continue the query.
        return true;
    }
    
    b2Vec2  m_point;
    b2Body* m_object;
};





@implementation MouseListener
b2World *temp_world;

+(id) initWithWorld:(b2World*)world
{
    NSLog(@"初始畫開始");
    temp_world=world;
            [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
	return self;
}




-(void) cleanup
{
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

+(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{

    //不知道為什麼從touches拔東西出來就是拔不到，所以從event硬拿
    NSSet *allTouches = [event allTouches];
            NSLog(@"檢查");
    //檢查這個地方有沒有這個物體存在
    int i=0;
    for (UITouch* touch in allTouches)
	{

        i++;
        b2Vec2 pos = [Helper toMeters:[Helper locationFromTouch:touch]];
        // Make a small box.
        b2AABB aabb;
        b2Vec2 d;
        d.Set(0.001f, 0.001f);
        aabb.lowerBound = pos - d;
        aabb.upperBound = pos + d;
        
        // Query the world for overlapping shapes.
        QueryCallback callback(pos);
        temp_world->QueryAABB(&callback, aabb);

        b2Body *body = callback.m_object;
        if (body)
        {
            
            NSObject* selectedObj = (__bridge NSObject*)body->GetUserData();
            NSString* otherClassName = NSStringFromClass([selectedObj class]);
            NSString* format = @"mousePressed%@:";//用reflection選出哪個物體是被press到的
            NSString* selectorString = [NSString stringWithFormat:format, otherClassName];
            SEL selector_mouseSelected = NSSelectorFromString(selectorString);

            if ([selectedObj respondsToSelector:selector_mouseSelected])
            {
                //其實是不用傳值，但是函數規定要傳值所以還是寫一下
//                id idNull=nil;
//                [selectedObj performSelector:selector_mouseSelected withObject:idNull];
            }   
            //pick the body

        }
    }
    
}

+(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

            NSLog(@"移動~");
    NSSet *allTouches = [event allTouches];
    //檢查這個地方有沒有這個物體存在
    int i=0;
    for (UITouch* touch in allTouches)
	{
        NSLog(@"移動!:%d",i);
        i=i+1;
    }
}

+(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
                NSLog(@"停止~");
    NSSet *allTouches = [event allTouches];
    //檢查這個地方有沒有這個物體存在
    int i=0;
    for (UITouch* touch in allTouches)
	{
        NSLog(@"結束移動:%d",i);
        i=i+1;
    }
}

@end