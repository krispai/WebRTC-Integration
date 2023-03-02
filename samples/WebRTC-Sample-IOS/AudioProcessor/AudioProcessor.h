//
//  AudioProcessor.h
//  AudioProcessor
//
//  Created by Arthur Hayrapetyan on 26.01.23.
//  Copyright © 2023 Krisp Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioProcessor : NSObject

- (instancetype)init;
+ (void)enableAudioFilter:(BOOL)enable;

@end

