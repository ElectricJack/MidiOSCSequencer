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
ClipPalletes           clips        = null;


Map<String, ControllerContext> contextsByName = new TreeMap<String, ControllerContext>();
List<ControllerContext>        activeContexts = new ArrayList<ControllerContext>();



void setup() {
  size(800, 400, P3D);

  //MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  //myBus     = new MidiBus(this, "Akai APC40", "Akai APC40"); // Create a new MidiBus object
  myBus     = new MidiBus(this, "APC40 mkII", "APC40 mkII");
  apc40     = new MidiController(sketchPath("config/apc40-mk2.json"));
  oscConfig = new OSCConfig(this, sketchPath("config/osc-actions.json"));
  clips     = new ClipPalletes(this, sketchPath("config/clip-palettes.json"));

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
  oscConfig.flushMessages();
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