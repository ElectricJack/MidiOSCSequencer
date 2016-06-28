import themidibus.*; //Import the library
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import oscP5.*;
import netP5.*;


MidiBus         myBus; // The MidiBus
MidiController  apc40;

List<List<MidiButton>> buttonCols   = new ArrayList<List<MidiButton>>();
List<MidiSlider>       faderSliders = new ArrayList<MidiSlider>();

OSCConfig              oscConfig    = null;

// Paged clip data
// MidiButton               lastButtonLeft  = null;
// MidiButton               lastButtonRight = null;
// Map<MidiButton, Integer> indexMap        = new TreeMap<MidiButton, Integer>();
// Map<MidiButton, Integer> effectIndexMap  = new TreeMap<MidiButton, Integer>();
// int                      currentPage     = 0;
// boolean                  shiftEnabled    = false;
// List<MidiButton>         pageButtons = new ArrayList<MidiButton>();


Map<String, ControllerContext> contextsByName = new TreeMap<String, ControllerContext>();
List<ControllerContext>        activeContexts = new ArrayList<ControllerContext>();


class ClipPallete {

}
class ClipPalletes {

}


void setup() {
  size(800, 400, P3D);

  //MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  //myBus     = new MidiBus(this, "Akai APC40", "Akai APC40"); // Create a new MidiBus object
  myBus     = new MidiBus(this, "APC40 mkII", "APC40 mkII");
  apc40     = new MidiController(sketchPath("config/apc40-mk2.json"));
  oscConfig = new OSCConfig(this, sketchPath("config/osc-actions.json"));

  //clips     = new ClipPalletes(sketchPath("config/clip-palettes.json"));

  apc40.setRect(0, 0, width, height);

  registerContext(new SequencerContext(apc40));
  registerContext(new BeatCounterContext(apc40));
  activateContext("Sequencer");
  activateContext("BeatCounter");

  // This seems to increase responsiveness on windows
  //  doesn't make much sense though, because the events are processed on their own thread.
  frameRate(200);
}

void draw() {
  background(0);

  for(ControllerContext context : activeContexts) {
    context.update();
  }

  apc40.draw();
}




void registerContext(ControllerContext context) {
  if(!contextsByName.containsKey(context.getName())) {
    contextsByName.put(context.getName(), context);
  }
}
void activateContext(String contextName) {
  if(contextsByName.containsKey(contextName)) {
    ControllerContext context = contextsByName.get(contextName);
    if(!activeContexts.contains(context)) {
      context.attach();
      activeContexts.add(context);
    }
  }
}
ControllerContext getContext(String contextName) {
  if(contextsByName.containsKey(contextName)) {
    return contextsByName.get(contextName);
  }
  return null;
}


/*
void updateBeatIndex() {

}
void updateCol(List<MidiButton> col, float t) {
  for (int i=0; i<col.size(); ++i) {
    MidiButton b = col.get(i);
    if (b.name.contains("Track")) continue;
    if (b.y < apc40.height*(0.8-t*0.8) - 0.5) {
      b.clearColor();
    } else {
      b.setColor(1);
    }
  }
}
void updatePageButtons() {
  for (int i=0, count=pageButtons.size(); i<count; ++i) {
    pageButtons.get(i).clearColor();
  }

  if ((frameCount / 30) % 2 == 0 && pageButtons.size() > 0) {
    pageButtons.get(currentPage).setColor(1);
    
    if (lastButtonLeft != null) lastButtonLeft.setColor(1);
    if (lastButtonRight != null) lastButtonRight.setColor(1);
  } else {
    clearLastPageButtons();
  }
}
void clearLastPageButtons() {
  if (lastButtonLeft != null) lastButtonLeft.clearColor();
  if (lastButtonRight != null) lastButtonRight.clearColor();
}*/




// ---------------------------------------------------------------------------- //
void noteOn  (int channel, int pitch, int velocity) {
  //println("noteOn c" + channel + " p" + pitch + " v" + velocity);
  apc40.noteOn(channel, pitch, velocity);
}
void noteOff (int channel, int pitch, int velocity) {
  //println("noteOff c" + channel + " p" + pitch + " v" + velocity);
  apc40.noteOff(channel, pitch, velocity);
}
void controllerChange(int channel, int number, int value) {
  //println("controllerChange c" + channel + " n" + number + " " + value );
  apc40.controllerChange(channel, number, value);
}
void oscEvent(OscMessage msg) {
  //msg.print();
}