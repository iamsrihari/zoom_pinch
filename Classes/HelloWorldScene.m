//
//  HelloWorldLayer.m
//  swm
//
//  Created by Srihari Muthyala on 7/11/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//
static const float MIN_SCALE = 0.5;
static const float MAX_SCALE = 2.0;
// Import the interfaces
#import "HelloWorldScene.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
	
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// create and initialize a Label
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World!!!" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		//CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		//label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		//[self addChild: label];
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// Completely transparent base to attach things that do scroll or zoom
		zoombase = [CCColorLayer layerWithColor:ccc4(0,0,0,0)];
		zoombase.position = ccp(0, 0);
		[self addChild:zoombase];		
		
		// Initialize the zoombase position
		ZB_last_posn = zoombase.position;
		
		// Completely transparent base to attach things that do not scroll or zoom
		nozoombase = [CCColorLayer layerWithColor:ccc4(0,0,0,0)];
		nozoombase.position = ccp(0, 0);
		[self addChild:nozoombase];		
		
		// Make background as a repeating icon that is larger than the screen
		//background = [CCSprite spriteWithFile:@"Icon.png"  rect:CGRectMake(0,0,size.width*2,size.height*2)];
		background = [CCSprite spriteWithFile:@"SWM.png"];
		// This is just to make it easier on my eyes :)
		background.opacity = 128;
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		background.position = ccp( size.width/2 , size.height/2 );
		[background.texture setTexParameters:&params];
		[zoombase addChild:background z:-1];
		
		// Add an icon that does not move with the background
		CCSprite *cocosguy = [CCSprite spriteWithFile:@"Default.png"];
		cocosguy.scale = 0.2;
		cocosguy.position = ccp(size.width/2, size.height/2);
		[nozoombase addChild:cocosguy];
		
		// Turn on UIGesture recognizers
		UIPanGestureRecognizer *panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)] autorelease];
		UIPinchGestureRecognizer *pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)] autorelease];
		UITapGestureRecognizer *singleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)] autorelease];
		singleTapGestureRecognizer.numberOfTapsRequired = 1;
		singleTapGestureRecognizer.numberOfTouchesRequired = 1;
		UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleDoubleTapFrom:)] autorelease];
		doubleTap.numberOfTapsRequired = 2;
		doubleTap.numberOfTouchesRequired = 1;
		[singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTap];
		
		// Add them to the director
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTapGestureRecognizer];
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:doubleTap];
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:panGestureRecognizer];
		[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];
		
		
	}
	return self;
}
// Point conversion routines
- (CGPoint)convertPoint:(CGPoint)point fromNode:(CCNode *)node {
    return [self convertToNodeSpace:[node convertToWorldSpace:point]];
}
- (CGPoint)convertPoint:(CGPoint)touchLocation toNode:(CCNode *)node {
	// do the inverse of the routine above
	// Where touchLocation is the result of what is called from the UIGestureRecognizer
	CGPoint newPos = [[CCDirector sharedDirector] convertToGL: touchLocation];
	newPos = [node convertToNodeSpace:newPos];
	return newPos;
}

// Zoom board
- (void)zoomLayer:(float)zoomScale {
	// Debugging purposes
	//	NSLog(@"zoombase scale: %f and scale from the gesture: %f\n",zoombase.scale, zoomScale);
	if ((zoombase.scale*zoomScale) <= MIN_SCALE) {
		zoomScale = MIN_SCALE/zoombase.scale;
	}
	if ((zoombase.scale*zoomScale) >= MAX_SCALE) {
		zoomScale =	MAX_SCALE/zoombase.scale;
	}
	zoombase.scale = zoombase.scale*zoomScale;
}

// Pan board
- (void)moveBoard:(CGPoint)translation from:(CGPoint)lastLocation {
	CGPoint target_position = ccpAdd(translation, lastLocation);
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// Insert routine here to check that target position is not out of bounds for your background
	// Remember that ZB_last_posn is a variable that holds the current position of zoombase
	zoombase.position = target_position;
	
}

// UIGesture recognizer routines
- (void)handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
}
- (void)handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer {
	// Here you could set this to do whatever you want, but I set it to reset the scale to 1
	zoombase.scale = 1;
}
- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [recognizer translationInView:recognizer.view];
		translation.y = -1 * translation.y;
		[self moveBoard:translation from:ZB_last_posn];
	}
}

- (void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
	if ((recognizer.state == UIGestureRecognizerStateBegan) || (recognizer.state == UIGestureRecognizerStateChanged)) {
		float zoomScale = [recognizer scale];
		[self zoomLayer:zoomScale];
		recognizer.scale = 1;
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		// Update the zoombase position
		ZB_last_posn = zoombase.position;
	}
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
