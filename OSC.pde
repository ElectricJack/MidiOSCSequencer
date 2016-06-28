public static final int OSC_INT   = 1;
public static final int OSC_FLOAT = 2;

public class OSCDest {
  public String     name;
  public String     ip;
  public int        port;
  public NetAddress address;
  public OSCDest(String name, String ip, int port) {
    this.name    = name;
    this.ip      = ip;
    this.port    = port;
    this.address = new NetAddress(ip, port);
  }
}
public class OSCAction {
  private int        type     = -1;
  private OSCConfig  parent   = null;
  private OSCDest    dest     = null;
  private OscMessage msg      = null;
  private String     path     = "";
  
  public OSCAction(OSCConfig parent, JSONObject data) {
    this.parent = parent;
    String[] oscPath = data.getString("osc").split(":");
    
    this.dest = parent.destinationsByName.get(oscPath[0]);
    this.path = oscPath[1];
    
    String type = data.getString("type");
    if (type.equals("int")) {
      this.type = OSC_INT;
      msg = new OscMessage(path);
      if (data.hasKey("value")) {
        int value = data.getInt("value");
        msg.add(value);
      }
    } else if(type.equals("float")) {
      this.type = OSC_FLOAT;
      msg = new OscMessage(path);
      if (data.hasKey("value")) {
        float value = data.getFloat("value");
        msg.add(value);
      }
    }
  }
  
  public void sendFloat(float value) {
    if (this.type == OSC_FLOAT) {
      //println("path: " + this.dest.address + " - " + path + " - " + value);
      //msg.clear();
      msg = new OscMessage(path);
      msg.add(value);
      parent.oscP5.send(this.msg, this.dest.address);
    }
  }
  
  public void sendInt(int value) {
    if (this.type == OSC_INT) {
      //println("path: " + this.dest.address + " - " + path + " - " + value);
      //msg.clear();
      msg = new OscMessage(path);
      msg.add(value);
      parent.oscP5.send(this.msg, this.dest.address);
    }
  }
  
  public void send() {
    parent.oscP5.send(this.msg, this.dest.address);
  }
}

/*
public class OSCPage {
  List<OSCAction> clipLaunchActions = new ArrayList<OSCAction>();
  List<OSCAction> clipLaunchShiftActions = new ArrayList<OSCAction>();
  List<OSCAction> effectsActions = new ArrayList<OSCAction>();
  
  public OSCPage(OSCConfig parent, JSONObject pageMap) {
    JSONArray effects         = pageMap.getJSONArray("effects");
    JSONArray clipLaunch      = pageMap.getJSONArray("clipLaunch");
    JSONArray clipLaunchShift = pageMap.getJSONArray("clipLaunch.shift");
    
    for(int i=0, count=clipLaunch.size(); i<count; ++i) {
      clipLaunchActions.add(new OSCAction(parent, clipLaunch.getJSONObject(i)));
    }
    for(int i=0, count=clipLaunchShift.size(); i<count; ++i) {
      clipLaunchShiftActions.add(new OSCAction(parent, clipLaunchShift.getJSONObject(i)));
    }
    for(int i=0, count=effects.size(); i<count; ++i) {
      effectsActions.add(new OSCAction(parent, effects.getJSONObject(i)));
    }
  }
  
  // Triggers a clip
  public void send(int index, boolean shift, int value) {
    if(shift) {
      //println("SHIFT!! "+index);
      if(index >= 0 && index < clipLaunchShiftActions.size()) {
        clipLaunchShiftActions.get(index).sendInt(value);
      }
    } else {
      if(index >= 0 && index < clipLaunchActions.size()) {
        clipLaunchActions.get(index).sendInt(value);
      }
    }
  }
  
  
  // Trigger an effect
  public void sendEffect(int index, int value) {
    if(index >= 0 && index < effectsActions.size()) {
      effectsActions.get(index).sendInt(value);
    }
  }
}*/

public class OSCConfig {
  public OscP5 oscP5         = null;
  public int   oscListenPort = 0;
  
  public List<OSCDest>          destinations       = new ArrayList<OSCDest>();
  public Map<String, OSCDest>   destinationsByName = new TreeMap<String,OSCDest>();
  //public List<OSCPage>          clipPages          = new ArrayList<OSCPage>();
  public Map<String, OSCAction> fadersByName       = new TreeMap<String,OSCAction>();
  public Map<String, OSCAction> buttonsByName      = new TreeMap<String,OSCAction>();
  
  // public void sendClip(int pageIndex, int clipIndex, boolean shiftEnabled, int value) {
  //   if (pageIndex >= 0 && pageIndex < clipPages.size()) {
  //     try {
  //       clipPages.get(pageIndex).send(clipIndex, shiftEnabled, value);
  //     } catch(Exception e) {
  //       println("Error sending clip message");
  //     }
  //   }
  // }
  
  // public void sendEffect(int pageIndex, int effectIndex, boolean enable) {
  //   if (pageIndex >= 0 && pageIndex < clipPages.size()) {
  //     try {
  //       clipPages.get(pageIndex).sendEffect(effectIndex, enable ? 1 : 0);
  //     } catch(Exception e) {
  //       println("Error sending effect message");
  //     }
  //   }
  // }
  
  public void sendFader(String faderName, float value) {
    OSCAction fader = fadersByName.get(faderName);
    if (fader != null)
      fader.sendFloat(value);
  }
  public void sendButton(String buttonName) {
    OSCAction button = buttonsByName.get(buttonName);
    if (button != null)
      button.send();
  }
  
  public OSCConfig(PApplet parent, String filePath) {
    JSONObject root = loadJSONObject(filePath);
    this.oscListenPort = root.getInt("oscListenPort");
    
    oscP5 = new OscP5(parent, this.oscListenPort);
    
    // Load the destinations
    JSONArray oscDestinations = root.getJSONArray("oscDestinations");
    for (int i=0, count=oscDestinations.size(); i<count; ++i) {
      JSONObject oscDest = oscDestinations.getJSONObject(i);
      
      OSCDest destination = new OSCDest(
        oscDest.getString("name"),
        oscDest.getString("ip"),
        oscDest.getInt("port")
      );
      
      destinations.add(destination);
      destinationsByName.put(destination.name, destination);
    }

    // Load the page map
    //JSONArray pageMap = root.getJSONArray("pageMap");
    //for (int i=0, count=pageMap.size(); i<count; ++i) {
    //  this.clipPages.add(new OSCPage(this, pageMap.getJSONObject(i)));
    //}
    
    // Load the faders
    JSONArray faders = root.getJSONArray("faders");
    for (int i=0, count=faders.size(); i<count; ++i) {
      JSONObject fader     = faders.getJSONObject(i);
      String     faderName = fader.getString("name");
      fadersByName.put(faderName, new OSCAction(this, fader.getJSONObject("action")));
    }
    
    // Load the buttons
    JSONArray buttons = root.getJSONArray("buttons");
    for (int i=0, count=buttons.size(); i<count; ++i) {
      JSONObject button     = buttons.getJSONObject(i);
      String     buttonName = button.getString("name");
      buttonsByName.put(buttonName, new OSCAction(this, button.getJSONObject("action")));
    }
  }
}