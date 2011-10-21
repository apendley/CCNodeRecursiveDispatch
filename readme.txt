CCNode(RecursiveDispatch):

Relevant Files:
CCNode+RecursiveDispatch.h
CCNode+RecursiveDispatch.m

Description:
A category with methods to propagate actions or dispatch of functions/selectors/blocks to all descendants (i.e. children on children of children etc.) of a node



ex: Run a FadeIn action on self and all of it's descendants

-(void)fadeIn
{
	CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:0.5f];
	[self runAction:fadeIn];
	
	// makes a copy of fadeIn and runs it on all descendants
	[self makeDescendantsRunAction:fadeIn];
}

ex: Run a FadeIn action on descendants of self using a block

-(void)fadeInDescendants:(float)duration
{
	[self visitDescendantsUsingBlock:^(CCNode* n) {
		[n runAction:[CCFadeIn actionWithDuration:duration]];
	}];
}

ex: Run a fade in action on descendants of self that conform to the CCRGBAProtocol using a block

-(void)fadeInDescendents:(float)duration
{
	[self visitDescendantsUsingBlock:^(CCNode* n) {
		if( [n conformsToProtocol:@protocol(CCRGBAProtocol)] )
			[n runAction:[CCFadeIn actionWithDuration:duration]];
	}];
}

ex: Run a fade in action on self and descendants that conform to the CCRGBAProtocol using a c function predicate

BOOL conformsToCCRGBAProtocol(CCNode* node)
{
	return [node conformsToProtocol:@protocol(CCRGBAProtocol)];
}

void fadeInSelfAndDescendants(float duration)
{
	CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:duration];
	[self runAction:fadeIn];
	[self makeDescendantsRunAction:fadeIn predicate:conformsToCCRGBAProtocol];
}

ex: set opacity on self and all of descendents that conform to the CCRGBAProtocol using a block as a visitor
-(void)setOpacityOnSelfAndDescendents:(opacity:(GLubyte)opacity
{
	self.opacity = opacity;
	[self visitDescendantsUsingBlock:^(CCNode *n) {
		if( [n conformsToProtocol:@protocol(CCRGBAProtocol)] )
			[(CCNode<CCRGBAProtocol>*)n setOpacity:opacity];
	}];
}

ex: set opacity on node and descendents that conform to the CCRGBAProtocol using using a c function as a visitor, and passing in the opacity via a NSNumber

void setOpacityOnNode(CCNode* node, id object)
{
	if( [node conformsToProtocol:@protocol(CCRGBAProtocol)] )
		[(CCNode<CCRGBAProtocol>*)node setOpacity:[object unsignedIntValue]];
}

void setOpacityOnNodeAndDescendants(CCNode<RGBAProtocol>* node, GLUbyte opacity)
{
	node.opacity = opacity;
	[node visitDescendants:setOpacityOnNode withObject:[NSNumber numberWithUnsignedInt:opacity]];
}

ex: setting opacity on self and propagating opacity to descendants that conform to CCRGBAProtocol

-(void)propagateOpacityToNode:(CCNode*)node
{
	if( [node conformsToProtocol:@protocol(CCRGBAProtocol)] )
		[(CCNode<CCRGBAProtocol>*)node setOpacity:self.opacity];
}

-(void)setOpacityOnSelfAndDescendents:(GLubyte)opacity
{
	self.opacity = opacity;
	[self visitDescendantsUsingTarget:self selector:@selector(propagateOpacityToNode:)];
}

ex: overriding setOpacity: on subclassed node conforming to CCRGBAProtocol (e.g. CCSprite) and propagating own opacity to all descendants conforming to CCRGBAProtocol

-(void)setOpacity:(GLubyte)opacity
{
	[super setOpacity:opacity];
	
	[self visitDescendantsUsingBlock:^(CCNode *node) {
		if( [node conformsToProtocol:@protocol(CCRGBAProtocol)] )
			[(CCNode<CCRGBAProtocol>*)node setOpacity:opacity_];
	}];
}

ex: create an aggregated bounding box using the bounding box of all of a node's descendents using a function as a visitor

void mergeBoundingBox(CCNode* node, void* data)
{
	CGRect* pRect = (CGRect*)data;	
	*pRect = CGRectUnion(*pRect, node.boundingBox);
}

-(CGRect)aggregateBoundingBoxForNode:(CCNode*)node
{
	CGRect boundingBox;
	boundingBox.origin = CGPointZero;
	boundingBox.size = node.contentSize;
	
	[node visitDescendants:mergeBoundingBox withData:&boundingBox];
	return boundingBox;
}

ex: create an aggregated bounding box using the bounding box of all of a node's descendents using a block as a visitor

-(CGRect)aggregateBoundingBoxForNode:(CCNode*)node
{
	__block CGRect boundingBox;
	boundingBox.origin = CGPointZero;
	boundingBox.size = node.contentSize;
	
	[node visitDescendantsUsingBlock:^(CCNode* n) {
		boundingBox = CGRectUnion(boundingBox, n.boundingBox);
	}];
	
	return boundingBox;
}

ex: pause scheduling and actions for a node and all descendants using makeDescendantsPerformSelector

void pauseNodeAndDescendants(CCNode* node)
{
	[node pauseSchedulerAndActions];
	[node makeDescendantsPerformSelector:@selector(pauseSchedulerAndActions)];
}

-(void)someMemberFunction
{
	[self pauseSchedulerAndActions];
	[self makeDescendantsPerformSelector:@selector(pauseSchedulerAndActions)];
}

ex: overriding pauseSchedulerAndActions on subclassed node to propagate pause to all descendents

-(void)pauseSchedulerAndActions
{
	[super pauseSchedulerAndActions];	
	[self makeDescendantsPerformSelector:@selector(pauseSchedulerAndActions)];
}