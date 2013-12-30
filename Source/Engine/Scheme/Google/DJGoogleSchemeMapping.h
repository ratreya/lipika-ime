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

@protocol DJGoogleSchemeMapping <NSObject>

-(id)initWithScheme:(DJGoogleInputScheme *)parentScheme;

-(void)createClassWithName:(NSString *)className;
-(void)createSimpleMappingWithInput:(NSString *)input output:(NSString *)output;
-(void)createSimpleMappingForClass:(NSString *)className input:(NSString *)input output:(NSString *)output;
-(void)createClassMappingWithPreInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput;
-(void)createClassMappingForClass:(NSString *)containerClass preInput:(NSString *)preInput className:(NSString *)className postInput:(NSString*)postInput isWildcard:(BOOL)isWildcard preOutput:(NSString *)preOutput postOutput:(NSString *)postOutput;

@end
