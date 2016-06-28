
public interface NoteOnCallback     { void noteOn(MidiButton button);          }
public interface NoteOffCallback    { void noteOff(MidiButton button);         }
public interface SliderCallback     { void change(MidiSlider slider, float t); }
public interface KnobCallback       { void change(MidiKnob knob, float t);     }

// ------------------------------------------------------------------------------------------------ //
public class OSCNoteOnCallback implements NoteOnCallback {
  private String oscAction;

  OSCNoteOnCallback(String oscAction) {
    this.oscAction = oscAction;
  }
  public void noteOn(MidiButton button) {
    oscConfig.sendButton(oscAction);
  }
}

public class OSCSliderCallback implements SliderCallback {
  private String oscAction;
  OSCSliderCallback(String oscAction) {
    this.oscAction = oscAction;
  }
  public void change(MidiSlider slider, float t) {
    oscConfig.sendFader(oscAction, t);
  }
}

public class OSCKnobCallback implements KnobCallback {
  private String oscAction;
  OSCKnobCallback(String oscAction) {
    this.oscAction = oscAction;
  }
  public void change(MidiKnob knob, float t) {
    oscConfig.sendFader(oscAction, t);
  }
}

// ------------------------------------------------------------------------------------------------ //
public class MidiControl implements Comparable<MidiControl> {
  public String type;
  public String name = "";
  public String midiPath;
  public float  x,y,w,h;
  public int    channel;
  public int    pitch;
  public int    number;
  public int    index;
  
  public int compareTo(MidiControl other) {
    return this.name.compareTo(other.name);
  } 
  
  public MidiControl(MidiController parent, String type, JSONObject definition) {
    this.type      = type;
    this.name      = definition.getString("name");
    this.midiPath  = definition.getString("midi");
    JSONArray rect = definition.getJSONArray("rect");
    
    String[] midiParts = this.midiPath.split(":");
    String   midiType  = midiParts[0];
    
    if ( midiType.equals("C") ) {
      this.channel = Integer.parseInt(midiParts[1]);
      this.number  = Integer.parseInt(midiParts[2]);
      parent.registerControl(channel, number, this);
    } else if(midiType.equals("N")) {
      this.channel = Integer.parseInt(midiParts[1]);
      this.pitch   = Integer.parseInt(midiParts[2]);
      parent.registerNote(this.channel, this.pitch, this);
    }
    
    this.x = rect.getFloat(0);
    this.y = rect.getFloat(1);
    this.w = rect.getFloat(2);
    this.h = rect.getFloat(3);
  }
  
  public boolean    intersectY(float y)        { return (y >= this.y && y <= this.y+h); }
  public boolean    intersectX(float x)        { return (x >= this.x && x <= this.x+w); }
  public boolean    contains(float x, float y) { return (x >= this.x && x <= this.x+w && y >= this.y && y <= this.y+h); }
  
  public boolean    isButton() { return type.equals("button"); }
  public boolean    isSlider() { return type.equals("slider"); }
  public boolean    isKnob()   { return type.equals("knob");   }
  public MidiSlider asSlider() { return (MidiSlider)this; }
  public MidiButton asButton() { return (MidiButton)this; }
  public MidiKnob   asKnob()   { return (MidiKnob)this;   }
  
  public void       draw(float sx, float sy)    { rect(x*sx,y*sy,w*sx,h*sy); }
  public void       noteOn(int velocity)        {}
  public void       noteOff(int velocity)       {}
  public void       controllerChange(int value) {}
}

// ------------------------------------------------------------------------------------------------ //
public class MidiButton extends MidiControl {
  boolean               on              = false;
  List<NoteOnCallback>  noteOnCallbacks  = new ArrayList<NoteOnCallback>();
  List<NoteOffCallback> noteOffCallbacks = new ArrayList<NoteOffCallback>();
  
  public MidiButton(MidiController parent, JSONObject definition) {
    super(parent, "button", definition);
  }
  
  public void addNoteOnCallback  (NoteOnCallback value)  { this.noteOnCallbacks.add(value);  }
  public void addNoteOffCallback (NoteOffCallback value) { this.noteOffCallbacks.add(value); }

  public void draw(float sx, float sy) {
    if (on) { fill(255,0,0);
    } else  { noFill(); }
    super.draw(sx,sy);
  }
  
  public void clearColor()             { this.setColor(0); }
  public void setColor(int colorIndex) { myBus.sendNoteOn(channel, pitch, colorIndex); }
  public void sendNoteOff()            { myBus.sendNoteOff(channel, pitch, 0); }
  
  public void noteOn(int velocity)  {
    for(int i=0, count=noteOnCallbacks.size(); i<count; ++i) {
      noteOnCallbacks.get(i).noteOn(this);
    }
    on = true;
  }
  public void noteOff(int velocity) {
    for(int i=0, count=noteOffCallbacks.size(); i<count; ++i) {
      noteOffCallbacks.get(i).noteOff(this);
    }
    on = false;
  }
}

// ------------------------------------------------------------------------------------------------ //
public class MidiSlider extends MidiControl {
  float                t = 0;
  List<SliderCallback> callbacks = new ArrayList<SliderCallback>();
  
  public MidiSlider(MidiController parent, JSONObject definition) {
    super(parent, "slider", definition);
  }
  
  public void controllerChange(int value) { 
    t = value / 128.0;
    myBus.sendControllerChange(channel, number, value);
    for(int i=0, count=callbacks.size(); i<count; ++i) {
      callbacks.get(i).change(this, t);
    }
  }
  
  public void addChangeCallback(SliderCallback callback) {
    this.callbacks.add(callback);
  }
  
  public float getPercent() { return t; }
  
  void draw(float sx, float sy) {
    noFill();
    super.draw(sx,sy);
    float sliderSize = 0.3;
    if(h > w) {
      float y2 = y + (h - sliderSize) * (1.0-t);
      fill(255);
      rect(x*sx, y2*sy, w*sx, sliderSize*sy);
    } else {
      float x2 = x + (w - sliderSize) * t;
      fill(255);
      rect(x2*sx, y*sy, sliderSize*sx, h*sy);
    }
  }
}

// ------------------------------------------------------------------------------------------------ //
public class MidiKnob extends MidiControl {
  float              t = 0;
  List<KnobCallback> callbacks = new ArrayList<KnobCallback>();
  
  public MidiKnob(MidiController parent, JSONObject definition) {
    super(parent, "knob", definition);
  }
  
  public void controllerChange(int value) { 
    t = value / 128.0;
    myBus.sendControllerChange(channel, number, value);
    for(int i=0, count=callbacks.size(); i<count; ++i) {
      callbacks.get(i).change(this, t);
    }
  }
  
  public void addChangeCallback(KnobCallback callback) {
    this.callbacks.add(callback);
  }
  
  void draw(float sx, float sy) {
    noFill();
    //super.draw(sx,sy);
    float x2 = x+w*0.5;
    float y2 = y+h*0.5;
    ellipse(x2*sx,y2*sy,w*sx,h*sy);
    
    fill(255);
    arc(x2*sx,y2*sy,w*sx,h*sy, 0, 2.0*PI*t, PIE);
  }
}