//
//  CCNode+RecursiveDispatch.h
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

#import "CCNode.h"

@class CCAction;

@interface CCNode(RecursiveDispatch)

typedef void (*CCDispatchFn)(CCNode*);
typedef void (*CCDispatchObjParam)(CCNode*, id);
typedef void (*CCDispatchDataParam)(CCNode*, void*);
typedef BOOL (*CCPredicateFn)(CCNode*);

-(void)makeDescendentsPerformSelector:(SEL)selector;
-(void)makeDescendentsPerformSelector:(SEL)selector predicate:(CCPredicateFn)predicate;
-(void)makeDescendentsPerformSelector:(SEL)selector target:(id)target predicateSelector:(SEL)predicateSelector;

-(void)makeDescendentsPerformSelector:(SEL)selector withObject:(id)object;
-(void)makeDescendentsPerformSelector:(SEL)selector withObject:(id)object predicate:(CCPredicateFn)predicate;
-(void)makeDescendentsPerformSelector:(SEL)selector withObject:(id)object predicateTarget:(id)target predicateSelector:(SEL)predicateSelector;

-(void)makeDescendentsRunAction:(CCAction*)action;
-(void)makeDescendentsRunAction:(CCAction*)action predicate:(CCPredicateFn)predicate;
-(void)makeDescendentsRunAction:(CCAction*)action predicateTarget:(id)target predicateSelector:(SEL)predicateSelector;

-(void)visitDescendents:(CCDispatchFn)function;
-(void)visitDescendents:(CCDispatchObjParam)function withObject:(id)object;
-(void)visitDescendents:(CCDispatchDataParam)function withData:(void*)data;

-(void)visitDescendentsUsingTarget:(id)target selector:(SEL)selector;
-(void)visitDescendentsUsingTarget:(id)target selector:(SEL)selector withObject:(id)object;
-(void)visitDescendentsUsingTarget:(id)target selector:(SEL)selector withData:(void*)data;

#if NS_BLOCKS_AVAILABLE

typedef void (^CCDispatchBlock)(CCNode*);
typedef BOOL (^CCPredicateBlock)(CCNode*);

-(void)makeDescendentsPerformSelector:(SEL)selector predicateBlock:(CCPredicateBlock)predicate;
-(void)makeDescendentsPerformSelector:(SEL)selector withObject:(id)object predicateBlock:(CCPredicateBlock)predicate;

-(void)makeDescendentsRunAction:(CCAction*)action predicateBlock:(CCPredicateBlock)predicate;

-(void)visitDescendentsUsingBlock:(CCDispatchBlock)block;

#endif

@end
