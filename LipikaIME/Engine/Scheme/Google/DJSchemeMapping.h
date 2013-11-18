/*
 * LipikaIME is a user-configurable phonetic Input Method Engine for Mac OS X.
 * Copyright (C) 2013 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

#import <Foundation/Foundation.h>

@class DJGoogleInputScheme;

@protocol DJSchemeMapping <NSObject>

-(id)initWithScheme:(DJGoogleInputScheme*)parentScheme;

-(void)createClassWithName:(NSString*)className;
-(void)createSimpleMappingWithKey:(NSString*)key value:(NSString*)value;
-(void)createSimpleMappingForClass:(NSString*)className key:(NSString*)key value:(NSString*)value;
-(void)createClassMappingWithPreKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue;
-(void)createClassMappingForClass:(NSString*)containerClass preKey:(NSString*)preKey className:(NSString*)className isWildcard:(BOOL)isWildcard preValue:(NSString*)preValue postValue:(NSString*)postValue;

@end
