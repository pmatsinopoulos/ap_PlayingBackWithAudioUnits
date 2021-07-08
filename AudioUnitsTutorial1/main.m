//
//  main.m
//  AudioUnitsTutorial1
//
//  Created by Panayotis Matsinopoulos on 4/7/21.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AUGraph.h>
#import <AudioToolbox/AUComponent.h>
#import <unistd.h>
#import <stdio.h>

#import "CheckError.h"
#import "GetAudioFileAudioStreamBasicDescription.h"
#import "GetNumberOfPackets.h"
#import "MyAUGraphPlayer.h"
#import "NSPrint.h"
#import "OpenAudioFile.h"
#import "PrintAudioFileDictionary.h"
#import "PrintAudioStreamBasicDescription.h"
#import "StopAudioUnitGraphPlayingBack.h"

void CreateMyAUGraph(MyAUGraphPlayer *player) {
  CheckError(NewAUGraph(&player->graph), "New Audio Unit Graph");
  
  // Creating a File Player Audio Unit Graph Node
  AudioComponentDescription generatorDescription = {0};
  generatorDescription.componentType = kAudioUnitType_Generator;
  generatorDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;
  generatorDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  AUNode filePlayerNode;
  CheckError(AUGraphAddNode(player->graph,
                            &generatorDescription,
                            &filePlayerNode),
             "Graph Add Audio Unit File Player Node");
  // ------------------------------------------------

  // Creating an Output Type Audio Unit with DefaultOuptut subtype
  AudioComponentDescription outputDefault = {0};
  outputDefault.componentType = kAudioUnitType_Output;
  outputDefault.componentSubType = kAudioUnitSubType_DefaultOutput;
  outputDefault.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  AUNode outputDefaultNode;
  CheckError(AUGraphAddNode(player->graph,
                            &outputDefault,
                            &outputDefaultNode),
             "Graph Add Audio Unit Output Node");
  // -----------------------------------------------------------------
  
  // Connect Nodes
  CheckError(AUGraphConnectNodeInput(player->graph,
                                     filePlayerNode,
                                     0,
                                     outputDefaultNode,
                                     0),
             "Connecting file player node to output node");

  // Open the Graph
  CheckError(AUGraphOpen(player->graph), "Opening Graph");  
  
  // Initialize the Graph
  CheckError(AUGraphInitialize(player->graph), "Initializing the Audio Unit Graph");
}

void PrepareFileAU(MyAUGraphPlayer *player) {
  AUNode filePlayerNode;
  CheckError(AUGraphGetIndNode(player->graph,
                               0,
                               &filePlayerNode),
             "Getting access to the file player node");
  
  AudioUnit fileAudioUnit;
  CheckError(AUGraphNodeInfo(player->graph,
                             filePlayerNode,
                             NULL,
                             &fileAudioUnit),
             "Getting the Audio Unit of the file player node");
  
  CheckError(AudioUnitSetProperty(fileAudioUnit,
                                  kAudioUnitProperty_ScheduledFileIDs,
                                  kAudioUnitScope_Global,
                                  0,
                                  &player->inputFile,
                                  sizeof(player->inputFile)),
             "Audio Unit setting property value for kAudioUnitProperty_ScheduledFileIDs");
  
  UInt64 packetsCount = 237;
  GetNumberOfPackets(player->inputFile, "Getting the number of packets from the input file", &packetsCount);
  
  // Tell the Audio Unit for file player to play the whole file
  ScheduledAudioFileRegion rgn;
  
  memset(&(rgn.mTimeStamp), 0, sizeof(rgn.mTimeStamp));
  rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
  rgn.mTimeStamp.mSampleTime = 0;
  
  rgn.mCompletionProc = NULL;
  rgn.mCompletionProcUserData = NULL;
  rgn.mAudioFile = player->inputFile;
  rgn.mLoopCount = 0;
  rgn.mStartFrame = 0;
  rgn.mFramesToPlay = packetsCount * player->inputFormat.mFramesPerPacket;

  CheckError(AudioUnitSetProperty(fileAudioUnit,
                                  kAudioUnitProperty_ScheduledFileRegion,
                                  kAudioUnitScope_Global,
                                  0,
                                  &rgn,
                                  sizeof(rgn)),
             "Setting the audio unit property kAudioUnitProperty_ScheduledFileRegion");

  // Tell when to start playing back
  AudioTimeStamp startTime;
  memset(&startTime, 0, sizeof(startTime));
  startTime.mFlags = kAudioTimeStampSampleTimeValid;
  startTime.mSampleTime = -1;

  CheckError(AudioUnitSetProperty(fileAudioUnit,
                                  kAudioUnitProperty_ScheduleStartTimeStamp,
                                  kAudioUnitScope_Global,
                                  0,
                                  &startTime,
                                  sizeof(startTime)),
             "Setting the desired start for the play back to be as soon as possible");

  player->fileDurationInSeconds = rgn.mFramesToPlay / player->inputFormat.mSampleRate;
}

void PrepareAudioUnitGraph(MyAUGraphPlayer *player) {
  CreateMyAUGraph(player);
  PrepareFileAU(player);
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    if (argc < 2) {
      NSLog(@"1st argument: You need to give the input file for playing back. You can use any Core Audio supported file such as .mp3, .aac, .m4a, .wav, .aif e.t.c.\n");
      return 1;
    }
    
    MyAUGraphPlayer player = {0};
    
    OpenAudioFile(argv[1], &player.inputFile);
    
    GetAudioFileAudioStreamBasicDescription(player.inputFile, &player.inputFormat);
    
    PrintAudioFileDictionary(player.inputFile);
    
    PrintAudioStreamBasicDescription(player.inputFormat);
    
    PrepareAudioUnitGraph(&player);
        
    NSPrint(@"--------------\n");
    NSPrint(@"Click <Enter> to start playing back...\n");
    getchar();
    
    CheckError(AUGraphStart(player.graph), "Starting AU Graph...");
    
    // We will terminate a little while (0.5 seconds) after the expected end of playback.
    Float64 sleepDuration = player.fileDurationInSeconds + 0.5;
    NSPrint(@"Sleeping for: %f to allow for playback to finish\n", sleepDuration);
    
    usleep((int)(sleepDuration * 1000 * 1000));
    
    StopAudioUnitGraphPlayingBack(player.graph);
    
    CheckError(AudioFileClose(player.inputFile), "closing the audio input file");
  }
  return 0;
}
