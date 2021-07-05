//
//  MyAUGraphPlayer.h
//  AudioUnitsTutorial1
//
//  Created by Panayotis Matsinopoulos on 4/7/21.
//

#ifndef MyAUGraphPlayer_h
#define MyAUGraphPlayer_h
#import <CoreAudioTypes/CoreAudioBaseTypes.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AUGraph.h>
#import <AudioToolbox/AUComponent.h>

typedef struct MyAUGraphPlayer {
  AudioStreamBasicDescription inputFormat;
  AudioFileID                 inputFile;
  
  AUGraph graph;
  AudioUnit fileAU;
} MyAUGraphPlayer;

#endif /* MyAUGraphPlayer_h */
