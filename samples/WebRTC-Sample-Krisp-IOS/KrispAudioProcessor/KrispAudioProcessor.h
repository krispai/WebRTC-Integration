//
//  KrispAudioProcessor.h
//  KrispAudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KrispAudioProcessor : NSObject

- (instancetype)initWithParams:(NSString*)weightFile size:(unsigned int)size;
+ (void)enableAudioFilter:(BOOL)enable;

@end

