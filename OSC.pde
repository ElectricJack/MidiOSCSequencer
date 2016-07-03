public static final int OSC_INT   = 1;
public static final int OSC_FLOAT = 2;

public class OSCDest {
  public String     name;
  public String     ip;
  public int        port;
  public NetAddress address;

  public OscBundle  activeBundle;

  public OSCDest(String name, String ip, int port) {
    this.name         = name;
    this.ip           = ip;
    this.port         = port;
    this.address      = new NetAddress(ip, port);
    this.activeBundle = new OscBundle();
  }

  public void flush(OSCConfig parent) {
    if (this.activeBundle.size() > 0) {
      try {
        parent.oscP5.send(this.activeBundle, this.address);
      } catch(Exception e) {
        e.printStackTrace();
      }
      //this.activeBundle.clear();
      this.activeBundle = new OscBundle();
    }
  }
}
public class OSCAction {
  private int        type     = -1;
  private OSCConfig  parent   = null;
  private OSCDest    dest     = null;
  private OscMessage msg      = null;
  private String     path     = "";
  private boolean    useBundles;
  
  public OSCAction(OSCConfig parent, JSONObject data, boolean useBundles) {
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

    this.useBundles = useBundles;
  }
  
  public OSCAction(OSCConfig parent, String path, int value, boolean useBundles) {
    this.parent = parent;
    String[] oscPath = path.split(":");
    this.dest = parent.destinationsByName.get(oscPath[0]);
    this.path = oscPath[1];
    this.type = OSC_INT;
    msg = new OscMessage(this.path);
    msg.add(value);

    this.useBundles = useBundles;
  }

  public OSCAction(OSCConfig parent, String path, float value, boolean useBundles) {
    this.parent = parent;
    String[] oscPath = path.split(":");
    this.dest = parent.destinationsByName.get(oscPath[0]);
    this.path = oscPath[1];
    this.type = OSC_FLOAT;
    msg = new OscMessage(this.path);
    msg.add(value);

    this.useBundles = useBundles;
  }


  public void sendFloat(float value) {
    if (this.type == OSC_FLOAT) {
      //println("path: " + this.dest.address + " - " + path + " - " + value);
      //msg.clear();
      msg = new OscMessage(path);
      msg.add(value);
      
      if (useBundles) {
        this.dest.activeBundle.add(this.msg);
      } else {
        parent.oscP5.send(this.msg, this.dest.address);
      }
    }
  }
  
  public void sendInt(int value) {
    if (this.type == OSC_INT) {
      //println("path: " + this.dest.address + " - " + path + " - " + value);
      //msg.clear();
      msg = new OscMessage(path);
      msg.add(value);

      if (useBundles) {
        this.dest.activeBundle.add(this.msg);
      } else {
        parent.oscP5.send(this.msg, this.dest.address);
      }
    }
  }
  
  public void send() {
    println("send " + this.msg + " to " + this.dest.address);
    if (useBundles) {
      this.dest.activeBundle.add(this.msg);
    } else {
      parent.oscP5.send(this.msg, this.dest.address);
    }
  }
}

public class OSCConfig {
  public OscP5 oscP5         = null;
  public int   oscListenPort = 0;

  private boolean useBundles = true;
  
  public List<OSCDest>          destinations       = new ArrayList<OSCDest>();
  public Map<String, OSCDest>   destinationsByName = new TreeMap<String,OSCDest>();
  public Map<String, OSCAction> fadersByName       = new TreeMap<String,OSCAction>();
  public Map<String, OSCAction> buttonsByName      = new TreeMap<String,OSCAction>();

  

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


    // Load the faders
    JSONArray faders = root.getJSONArray("faders");
    for (int i=0, count=faders.size(); i<count; ++i) {
      JSONObject fader     = faders.getJSONObject(i);
      String     faderName = fader.getString("name");
      fadersByName.put(faderName, new OSCAction(this, fader.getJSONObject("action"), useBundles));
    }
    
    // Load the buttons
    JSONArray buttons = root.getJSONArray("buttons");
    for (int i=0, count=buttons.size(); i<count; ++i) {
      JSONObject button     = buttons.getJSONObject(i);
      String     buttonName = button.getString("name");
      buttonsByName.put(buttonName, new OSCAction(this, button.getJSONObject("action"), useBundles));
    }
  }

  void flushMessages() {
    if (useBundles) {
      for(OSCDest dest : destinations) {
        dest.flush(this);
      }
    }
  }

  OSCAction newAction(String message, int value) {
    return new OSCAction(this, message, value, useBundles);
  }
  OSCAction newAction(String message, float value) {
    return new OSCAction(this, message, value, useBundles);
  }
}

