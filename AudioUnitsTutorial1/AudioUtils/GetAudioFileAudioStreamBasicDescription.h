//
//  GetAudioFileAudioStreamBasicDescription.h
//  AudioUnitsTutorial1
//
//  Created by Panayotis Matsinopoulos on 4/7/21.
//

#ifndef GetAudioFileAudioStreamBasicDescription_h
#define GetAudioFileAudioStreamBasicDescription_h
#import <AudioToolbox/AudioFile.h>

void GetAudioFileAudioStreamBasicDescription(AudioFileID iAudioFileHandler,
                                             AudioStreamBasicDescription *oAudioFormat);

#endif /* GetAudioFileAudioStreamBasicDescription_h */
