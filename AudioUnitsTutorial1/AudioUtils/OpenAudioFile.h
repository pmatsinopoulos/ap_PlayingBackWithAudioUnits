//
//  OpenAudioFile.h
//  AudioUnitsTutorial1
//
//  Created by Panayotis Matsinopoulos on 4/7/21.
//

#ifndef OpenAudioFile_h
#define OpenAudioFile_h

#import <AudioToolbox/AudioFile.h>

void OpenAudioFile(const char *iFileName, AudioFileID *oAudioFileID);

#endif /* OpenAudioFile_h */
