
public class MidiController {
  public float             width;
  public float             height;
  public String            controllerName;
  public List<MidiControl> controls = new ArrayList<MidiControl>();
  
  private Map<Integer, Map<Integer, MidiControl>> noteMap    = null;
  private Map<Integer, Map<Integer, MidiControl>> controlMap = null;

  public MidiController(String filePath) {
    this.noteMap    = new TreeMap<Integer, Map<Integer, MidiControl>>();
    this.controlMap = new TreeMap<Integer, Map<Integer, MidiControl>>();

    JSONObject root     = loadJSONObject(filePath);
    this.width          = root.getFloat("width");
    this.height         = root.getFloat("height");
    this.controllerName = root.getString("name");
    JSONArray jsonControls  = root.getJSONArray("controls");
    
    for(int i=0, count=jsonControls.size(); i<count; ++i) {
      JSONObject definition = jsonControls.getJSONObject(i);
      String     type = definition.getString("type");
      if      ( type.equals("button") ) { this.controls.add(new MidiButton(this, definition)); }
      else if ( type.equals("slider") ) { this.controls.add(new MidiSlider(this, definition)); }
      else if ( type.equals("knob")   ) { this.controls.add(new MidiKnob(this, definition));   }
    }
  }
  
  float x,y, pixelWidth, pixelHeight;
  
  public void setRect(float x, float y, float width, float height) {
    this.x = x;
    this.y = y;
    this.pixelWidth = width;
    this.pixelHeight = height;
  }
  public void draw() {
    stroke(255);
    noFill();
    float sx = pixelWidth / this.width;
    float sy = pixelHeight / this.height;
    pushMatrix();
      translate(x,y);
      for(int i=0; i<this.controls.size(); ++i) {
        MidiControl c = controls.get(i);
        c.draw(sx, sy);
      }
    popMatrix();
  }
  
  public MidiControl getControlNamed(String name) {
    for(int i=0, count=controls.size(); i<count; ++i) {
      MidiControl control = controls.get(i);
      if (control.name.equals(name)) {
        return control;
      }
    }
    return null;
  }
  
  public MidiButton getButtonNamed(String name) {
    MidiControl control = getControlNamed(name);
    return (control != null && control.isButton())? control.asButton(): null;
  }

  public MidiSlider getSliderNamed(String name) {
    MidiControl control = getControlNamed(name);
    if (control == null) {
      println("Couldn't find slider named: "+name);
    }
    return (control != null && control.isSlider())? control.asSlider(): null;
  }

  public MidiKnob getKnobNamed(String name) {
    MidiControl control = getControlNamed(name);
    return (control != null && control.isKnob())? control.asKnob(): null;
  }
  
  public MidiControl getControlAt(float x, float y) {
    for(int i=0, count=controls.size(); i<count; ++i) {
      MidiControl control = controls.get(i);
      if (control.contains(x,y)) {
        return control;
      }
    }
    return null;
  }
  
  public void getButtonsAtY(float y, List<MidiButton> out) {
    for(int i=0, count=controls.size(); i<count; ++i) {
      MidiControl control = controls.get(i);
      if (control.intersectY(y) && control.isButton()) {
        out.add(control.asButton());
      }
    }
  }
  public void getButtonsAtX(float x, List<MidiButton> out) {
    for(int i=0, count=controls.size(); i<count; ++i) {
      MidiControl control = controls.get(i);
      if (control.intersectX(x) && control.isButton()) {
        out.add(control.asButton());
      }
    }
  }
  
  public void registerNote(int channel, int pitch, MidiControl handler) {
    if (!this.noteMap.containsKey(channel)) {
      this.noteMap.put(channel, new TreeMap<Integer, MidiControl>());
    }
    this.noteMap.get(channel).put(pitch, handler);
  }
  
  public void registerControl(int channel, int number, MidiControl handler) {
    if (!this.controlMap.containsKey(channel)) {
      this.controlMap.put(channel, new TreeMap<Integer, MidiControl>());
    }
    this.controlMap.get(channel).put(number, handler);
  }
  
  public void noteOn(int channel, int pitch, int velocity) {
    if (this.controlMap.containsKey(channel)) {
      Map<Integer,MidiControl> map = this.noteMap.get(channel);
      if (map.containsKey(pitch)) {
        map.get(pitch).noteOn(velocity);
      }
    }
  }
  public void noteOff(int channel, int pitch, int velocity) {
    if (this.controlMap.containsKey(channel)) {
      Map<Integer,MidiControl> map = this.noteMap.get(channel);
      if (map.containsKey(pitch)) {
        map.get(pitch).noteOff(velocity);
      }
    }
  }
  public void controllerChange(int channel, int number, int value) {
    if (this.controlMap.containsKey(channel)) {
      Map<Integer,MidiControl> map = this.controlMap.get(channel);
      if (map.containsKey(number)) {
        map.get(number).controllerChange(value);
      }
    }
  }
}