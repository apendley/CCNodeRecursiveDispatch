//
//  CCNode+RecursiveDispatch.m
//
//  Created by Aaron Pendley on 9/15/11.
//  Copyright 2011 Aaron Pendley.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCNode+RecursiveDispatch.h"
#import "CCAction.h"

typedef BOOL (*CCPredicateImp)(id, SEL, CCNode*);
typedef void (*CCDispatchParamImp)(id, SEL, CCNode*, void*);

@implementation CCNode(RecursiveDispatch)

-(void)makeDescendantsPerformSelector:(SEL)selector
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		[child performSelector:selector];
		[child makeDescendantsPerformSelector:selector];
	}	
}

-(void)makeDescendantsPerformSelector:(SEL)selector predicate:(CCPredicateFn)predicate
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicate(child) )
			[child performSelector:selector];
		
		[child makeDescendantsPerformSelector:selector predicate:predicate];
	}	
}

-(void)makeDescendantsPerformSelector:(SEL)selector target:(id)target predicateSelector:(SEL)predicateSelector
{
	CCPredicateImp predicateImp = (CCPredicateImp)[target methodForSelector:predicateSelector];	
	
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicateImp(target, predicateSelector, child) )
			[child performSelector:selector];
		
		[child makeDescendantsPerformSelector:selector target:target predicateSelector:predicateSelector];
	}	
}

-(void)makeDescendantsPerformSelector:(SEL)selector withObject:(id)object
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		[child performSelector:selector withObject:object];
		[child makeDescendantsPerformSelector:selector withObject:object];
	}	
}

-(void)makeDescendantsPerformSelector:(SEL)selector withObject:(id)object predicate:(CCPredicateFn)predicate
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicate(child) )
			[child performSelector:selector withObject:object];
		
		[child makeDescendantsPerformSelector:selector withObject:object predicate:predicate];
	}	
}

-(void)makeDescendantsPerformSelector:(SEL)selector withObject:(id)object predicateTarget:(id)target predicateSelector:(SEL)predicateSelector
{
	CCPredicateImp predicateImp = (CCPredicateImp)[target methodForSelector:predicateSelector];	
	
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{		
		if( predicateImp(target, predicateSelector, child) )
			[child performSelector:selector withObject:object];
		
		[child makeDescendantsPerformSelector:selector withObject:object predicateTarget:target predicateSelector:predicateSelector];
	}	
}

-(void)makeDescendantsRunAction:(CCAction*)action;
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		[child runAction:[[action copy] autorelease]];
		[child makeDescendantsRunAction:action];
	}	
}

-(void)makeDescendantsRunAction:(CCAction*)action predicate:(CCPredicateFn)predicate
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicate(child) )			
			[child runAction:[[action copy] autorelease]];
		
		[child makeDescendantsRunAction:action predicate:predicate];
	}	
}

-(void)makeDescendantsRunAction:(CCAction*)action predicateTarget:(id)target predicateSelector:(SEL)predicateSelector
{
	CCPredicateImp predicateImp = (CCPredicateImp)[target methodForSelector:predicateSelector];	
	
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicateImp(target, predicateSelector, child) )
			[child runAction:[[action copy] autorelease]];
		
		[child makeDescendantsRunAction:action predicateTarget:target predicateSelector:predicateSelector];
	}	
}

-(void)visitDescendants:(CCDispatchFn)function
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		function(child);
		[child visitDescendants:function];
	}	
}

-(void)visitDescendants:(CCDispatchObjParam)function withObject:(id)object
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		function(child, object);
		[child visitDescendants:function withObject:object];
	}	
}

-(void)visitDescendants:(CCDispatchDataParam)function withData:(void*)data
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		function(child, data);
		[child visitDescendants:function withData:data];
	}	
}

-(void)visitDescendantsUsingTarget:(id)target selector:(SEL)selector
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		[target performSelector:selector withObject:child];
		[child visitDescendantsUsingTarget:target selector:selector];
	}	
}

-(void)visitDescendantsUsingTarget:(id)target selector:(SEL)selector withObject:(id)object
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		[target performSelector:selector withObject:child withObject:object];
		[child visitDescendantsUsingTarget:target selector:selector withObject:object];
	}	
}

-(void)visitDescendantsUsingTarget:(id)target selector:(SEL)selector withData:(void*)data
{
	CCDispatchParamImp dispatchImp = (CCDispatchParamImp)[target methodForSelector:selector];	
	
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		dispatchImp(target, selector, child, data);
		[child visitDescendantsUsingTarget:target selector:selector withData:data];
	}	
}

#if NS_BLOCKS_AVAILABLE

-(void)makeDescendantsPerformSelector:(SEL)selector predicateBlock:(CCPredicateBlock)predicate
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicate(child) )
			[child performSelector:selector];
		
		[child makeDescendantsPerformSelector:selector predicateBlock:predicate];
	}	
}

-(void)makeDescendantsPerformSelector:(SEL)selector withObject:(id)object predicateBlock:(CCPredicateBlock)predicate
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicate(child) )
			[child performSelector:selector withObject:object];
		
		[child makeDescendantsPerformSelector:selector withObject:object predicateBlock:predicate];
	}	
}

-(void)makeDescendantsRunAction:(CCAction*)action predicateBlock:(CCPredicateBlock)predicate
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		if( predicate(child) )			
			[child runAction:[[action copy] autorelease]];
		
		[child makeDescendantsRunAction:action predicateBlock:predicate];
	}	
}

-(void)visitDescendantsUsingBlock:(CCDispatchBlock)block
{
	CCNode* child;
	CCARRAY_FOREACH(self.children, child)
	{
		block(child);
		[child visitDescendantsUsingBlock:block];
	}	
}

#endif

@end
