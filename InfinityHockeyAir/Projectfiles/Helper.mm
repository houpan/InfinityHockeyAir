//
//  Helper.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//


#import "Helper.h"
#import "b2Math.h"
#import "b2Settings.h"

@implementation Helper


// convenience method to convert a CGPoint to a b2Vec2
+(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
+(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}
//回傳某個永遠到不了的地方
+(b2Vec2) speedBooster:(b2Vec2)velocityInput andMultiplier:(int)multiplier
{
	return b2Vec2(velocityInput.x*multiplier,velocityInput.y*multiplier);
}

+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

+(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

+(CGPoint) screkenCenter
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}


+ (CGPoint) makeWithX: (float)x Y: (float)y
{
    CGPoint vec;
    vec.x = x;
    vec.y = y;
    return vec;
}

+ (CGPoint) makeIdentity { return [self makeWithX: 0.0f Y: 0.0f]; }

+ (CGPoint) add: (CGPoint) vec1 to: (CGPoint) vec2
{
    vec2.x += vec1.x;
    vec2.y += vec1.y;
    return vec2;
}

+ (CGPoint) truncate: (CGPoint) vec to: (float) max
{
    // this is not true truncation, but is much faster
    if (vec.x > max) vec.x = max;
    if (vec.y > max) vec.y = max;
    if (vec.y < -max) vec.y = -max;
    if (vec.x < -max) vec.x = -max;
    return vec;
}

+ (CGPoint) multiply: (CGPoint) vec by: (float) factor
{
    vec.x *= factor;
    vec.y *= factor;
    return vec;
}

+ (float) lengthSquared: (CGPoint) vec
{
    return (vec.x*vec.x + vec.y*vec.y);
}


+ (CGPoint) invert: (CGPoint) vec
{
    vec.x *= -1;
    vec.y *= -1;
    return vec;
}

+ (CGPoint) subtract: (CGPoint) vec2 of: (CGPoint) vec1
{
    vec2.x -= vec1.x;
    vec2.y -= vec1.y;
    
    return vec2;
}

+ (CGPoint) divide: (CGPoint) vec2 by: (double) under
{
    vec2.x /= under;
    vec2.y /= under;
    
    return vec2;
}



+ (BOOL) compare: (CGPoint) vec2 with: (CGPoint) vec1
{
    return vec2.x==vec1.x&&vec2.y==vec1.y;
}

+(CGPoint) normalization:(CGPoint)first
{

    return [self makeWithX:first.x/sqrt(first.x*first.x + first.y*first.y) Y:first.y/sqrt(first.x*first.x + first.y*first.y)];
}

+(CGFloat) distanceBetweenPoints:(CGPoint)first between:(CGPoint) second
{
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}


@end
