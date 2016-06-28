
class BeatCounter {
  float firstBeatTime     = 0;
  float lastBeatTime      = 0;
  int   beatIndex         = 0;
  float beatTimes[]       = new float[4];
  float averageBeatLength = 0;
  int   totalBeatCount    = 0;
  int   lastBeatIndex     = 0;
  
  void tap() {
    float beatTime = millis() / 1000.0;
    if (firstBeatTime == 0) {
      firstBeatTime = beatTime;
      lastBeatTime  = beatTime;
    } else {
      if (averageBeatLength != 0) {
         float timeSinceFirst  = beatTime - firstBeatTime;
         float timeSinceLast   = beatTime - lastBeatTime;
         float beatsSinceFirst = floor(timeSinceFirst / averageBeatLength);
         float beatsSinceLast  = floor(timeSinceLast / averageBeatLength);
         if (beatsSinceLast > 4) {
           lastBeatTime = firstBeatTime + beatsSinceFirst * averageBeatLength;
         }
      }
      
      averageBeatLength = beatTimes[beatIndex++] = beatTime - lastBeatTime;
      
      lastBeatTime  = beatTime;
      beatIndex    %= beatTimes.length;

      ++totalBeatCount;
    }
    
    if (totalBeatCount > 4) {
      averageBeatLength = (beatTimes[0]+beatTimes[1]+beatTimes[2]+beatTimes[3]) * 0.25;
    }
  }
  void tapFirst() {
    firstBeatTime = millis() / 1000.0;
    lastBeatIndex = 0;
  }
  int getBeatIndex() {
    if (averageBeatLength == 0) {
      return 0;
    }
    
    float currentTime     = millis() / 1000.0;
    float timeSinceFirst  = (currentTime - firstBeatTime);
    float beatsSinceFirst = floor(timeSinceFirst / averageBeatLength);
    int   beatIndex       = (int)(beatsSinceFirst % 4);
    
    if (beatsSinceFirst > lastBeatIndex) {
      lastBeatIndex = (int)beatsSinceFirst;
      return beatIndex;
    }
    
    return lastBeatIndex % 4;
  }
}