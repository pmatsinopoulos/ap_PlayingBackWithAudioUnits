//
//  CharPointerFilenameToNSURLp.m
//  AudioUnitsTutorial1
//
//  Created by Panayotis Matsinopoulos on 4/7/21.
//

#import <Foundation/Foundation.h>

NSURL *CharPointerFilenameToNSURLp(const char *inFilename) {
  NSString *filePath = [[NSString stringWithUTF8String:inFilename] stringByExpandingTildeInPath];
  return [NSURL fileURLWithPath:filePath];
}

