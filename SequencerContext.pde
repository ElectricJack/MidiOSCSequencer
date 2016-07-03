
public class ClipEvent implements Serializable {
  
  public int           clipIndex = -1;
  public List<Integer> clips     = new ArrayList<Integer>();

  public String       getType() { return "ClipEvent"; }
  public Serializable clone()   { return new ClipEvent(); }
  public void serialize(Serializer s) {
    clipIndex = s.serialize("clipIndex", clipIndex);
    if (s.isLoading()) {
      int clipCount = 0;
      clipCount = s.serialize("clipCount", clipCount);
      clips.clear();
      for(int i=0; i<clipCount; ++i) {
        clips.add(s.serialize("c"+i, 0));
      }
    } else {
      int clipCount = clips.size();
      s.serialize("clipCount", clipCount);
      for(int i=0; i<clipCount; ++i) {
        s.serialize("c"+i, (int)clips.get(i));
      }
    }
  }

  public boolean toggleClip(int clipIndex) {
    if (clips.contains(clipIndex)) {
      clips.remove(new Integer(clipIndex));
      return false;
    } else {
      clips.add(clipIndex);
      return true;
    }
  }
}

public class FloatChannel implements Serializable {
  float[] values = new float[256];

  public String       getType() { return "FloatChannel"; }
  public Serializable clone()   { return new FloatChannel(); }
  public void serialize(Serializer s) {
    for(int i=0; i<values.length; ++i) {
      values[i] = s.serialize("v"+i, values[i]);
    }
  }
}

public class Sequence implements Serializable {
  int                 beatsPerMeasure = 8;
  int                 pageCount       = 1;
  List<ClipEvent>     clipEvents      = new ArrayList<ClipEvent>();
  List<FloatChannel>  floatChannels   = new ArrayList<FloatChannel>();

  public String       getType() { return "Sequence"; }
  public Serializable clone()   { return new Sequence(); }
  public void serialize(Serializer s) {
    beatsPerMeasure = s.serialize("beatsPerMeasure", beatsPerMeasure);
    pageCount       = s.serialize("pageCount",       pageCount);
    s.serialize("clipEvents",    clipEvents);
    s.serialize("floatChannels", floatChannels);
  }


  public Sequence() {
    resize(1);
  }

  public boolean toggleClip(int page, int beatIndex, int clipIndex) {
    int index = page*16 + beatIndex;
    if(index >= 0 && index < clipEvents.size()) {
      ClipEvent clipEvent = clipEvents.get(index);
      return clipEvent.toggleClip(clipIndex);
    }
    return false;
  }

  public ClipEvent getClip(int index) {
    if(index >=0 && index < clipEvents.size()) {
      return clipEvents.get(index);
    }
    return null;
  }
  public int  getPageCount() { return pageCount; }
  public void resize(int pageCount) {
    this.pageCount = pageCount;
    int eventCount = 16*pageCount;
    for(int i=clipEvents.size(); i<eventCount; ++i) {
      clipEvents.add(new ClipEvent());
    }
  }
}

public class SequenceList implements Serializable
{
  public List<Sequence> sequences = new ArrayList<Sequence>();

  public String       getType() { return "SequenceList"; }
  public Serializable clone()   { return new SequenceList(); }
  public void serialize(Serializer s) {
    s.serialize("sequences", sequences);
  }

  public int      size()          { return sequences.size();     }
  public Sequence get(int index)  { return sequences.get(index); }
  public void     add(Sequence s) { sequences.add(s); }
}




public class SequencerContext extends ControllerContext
{
  final int pageBGColor     = 32;
  final int pageActiveColor = 25;
  final int pageExistColor  = 37;

  final int clipBGColor         = 7;
  final int clipActiveColor     = 4;
  final int clipHighlightColor  = 5;
  final int seqBGColor          = 0;
  final int seqActiveColor      = 34;
  final int seqCurrentBeatColor = 50;


  int                activePage      = 0;
  Sequence           activeSequence  = new Sequence();
  int                activeClipIndex = 0;
  int                activeSequenceIndex = 0;
  SequenceList       sequences       = new SequenceList();

  MidiButton[]       pageButtons     = new MidiButton[8];
  MidiButton[]       clipButtons     = new MidiButton[16];
  MidiButton[]       sequenceButtons = new MidiButton[16];
  BeatCounterContext beatCounter;

  boolean            changeSequence = true;
  int                sequenceBank = 0;
  int                paletteBank  = 0;

  int                lastBeatIndex = 0;

  boolean            sequenceChanged = false;
  
  boolean[]          enabledLayers = new boolean[8];

  JSONSerializer     serializer;




  class PageButtonHandler implements NoteOnCallback, NoteOffCallback {
    int index;
    int startHoldTime;
    public PageButtonHandler(int index) { this.index = index; }
    public void noteOn(MidiButton button) {
      startHoldTime = millis();
    }
    public void noteOff(MidiButton button) {
      int   endHoldTime = millis();
      float timeElapsed = (endHoldTime - startHoldTime) / 1000.0;
      if (timeElapsed > 1.0) {
        resizeSequenceToPages(index+1);
      } else {
        activePage = index;
      }
      updatePageColors();
    }
  }
  class ClipButtonHandler implements NoteOnCallback, NoteOffCallback {
    int row, col;
    public ClipButtonHandler(int row, int col) {
      this.row = row;
      this.col = col;
    }
    public void noteOn(MidiButton button) {
      activateClip(row, col);
      button.setColor(clipHighlightColor);
    }
    public void noteOff(MidiButton button) {
      activateClip(row, -1);
      button.setColor(clipActiveColor);
    }
  }
  class SequenceButtonHandler implements NoteOnCallback, NoteOffCallback {
    int     beatIndex;
    boolean active;
    public SequenceButtonHandler(int beatIndex) {
      this.beatIndex = beatIndex;
    }
    public void noteOn(MidiButton button) {
      active = activeSequence.toggleClip(activePage, beatIndex, activeClipIndex);
      sequenceChanged = true;
      updateColor(button);
    }
    public void noteOff(MidiButton button) {
      updateColor(button);
    }
    void updateColor(MidiButton button) {
      if (active) {
        button.setColor(seqActiveColor);
      } else {
        button.setColor(seqBGColor);
      }
    }
  }
  class ActiveSequencePaletteHandler implements NoteOnCallback, NoteOffCallback {
    int index;
    public ActiveSequencePaletteHandler(int index) { this.index = index; }
    public void noteOn(MidiButton button) {
      // Should we change the sequence?
      if (changeSequence) {
        setActiveSequence(sequenceBank*8 + index);
      } else { // Or the clip palette?
        clips.setActivePalette(paletteBank*8 + index);
      }
    }
    public void noteOff(MidiButton button) {
      updateSequencePaletteButtons();
      if (changeSequence) {
        activePage = 0;
        updatePageColors();
      }
    }
  }
  class ActiveBankHandler implements NoteOnCallback, NoteOffCallback {
    int index;
    public ActiveBankHandler(int index) { this.index = index; } 
    public void noteOn(MidiButton button) {
      if (changeSequence) {
        sequenceBank = index;
      } else {
        paletteBank = index;
      }
    }
    public void noteOff(MidiButton button) {
      updateSequencePaletteButtons();
    }
  }
  class EnableLayerSequenceHandler implements NoteOnCallback, NoteOffCallback {
    int index;
    public EnableLayerSequenceHandler(int index) { this.index = index; }
    void noteOn(MidiButton button)  {} //@TODO
    void noteOff(MidiButton button) {} //@TODO
  }

  class ClipsChangeOpacityHandler implements SliderCallback{
    int index;
    public ClipsChangeOpacityHandler(int index) { this.index = index; }
    public void change(MidiSlider slider, float t) {
      clips.setOpacity(index, t);
    }
  }
  class ClipsSoloHandler implements NoteOnCallback, NoteOffCallback {
    int index;
    public ClipsSoloHandler(int index) { this.index = index; }
    public void noteOn(MidiButton button)  { clips.soloRow(index, true); }
    public void noteOff(MidiButton button) { clips.soloRow(index, false); }
  }
  class ClipsBlankHandler implements NoteOnCallback, NoteOffCallback {
    int index;
    public ClipsBlankHandler(int index) { this.index = index; }
    public void noteOn(MidiButton button)  { clips.blankRow(index, true); }
    public void noteOff(MidiButton button) { clips.blankRow(index, false); }
  }

  void updateSequencePaletteButtons() {
    for(int i=0; i<8; ++i) {
      MidiButton button = controller.getButtonNamed("Clip Stop " + (i+1));
      button.setColor(0);
    }

    for(int i=0; i<5; ++i) {
      MidiButton button = controller.getButtonNamed("Scene Launch " + (i+1));
      button.setColor(0);
    }

    int clipIndex, sceneIndex;
    if(changeSequence) {
      clipIndex  = activeSequenceIndex % 8 + 1;
      sceneIndex = sequenceBank + 1;
    } else {
      clipIndex  = clips.getActivePaletteIndex() % 8 + 1;
      sceneIndex = paletteBank + 1;
    }

    MidiButton button = controller.getButtonNamed("Clip Stop " + clipIndex);
    button.setColor(1);
    button = controller.getButtonNamed("Scene Launch " + sceneIndex);
    button.setColor(1);
  }
  void updatePageColors() {
    int pageCount = activeSequence.getPageCount();
    for(int i=0; i<8; ++i) {
      MidiButton button = controller.getButtonNamed("["+(i+1)+",1]");
      
      if (i < pageCount) {
        button.setColor(pageExistColor);
      } else {
        button.setColor(pageBGColor);
      }
    }

    MidiButton button = controller.getButtonNamed("["+(activePage+1)+",1]");
    button.setColor(pageActiveColor);
  }
  void resizeSequenceToPages(int pages) {
    activeSequence.resize(pages);
  }


  public SequencerContext(PApplet parent, MidiController controller) {
    super(controller);
    serializer = new JSONSerializer(parent);
    serializer.registerType(new SequenceList());
    serializer.registerType(new Sequence());
    serializer.registerType(new FloatChannel());
    serializer.registerType(new ClipEvent());

    loadSequences();

    int sequencesToCreate = 8 - (sequences.size() % 8);
    if(sequences.size() == 0 || sequencesToCreate < 8) {
      println("Creating " + sequencesToCreate + " sequences.");
      for(int i=0; i<sequencesToCreate; ++i) {
        sequences.add(new Sequence());
      }
    }
    setActiveSequence(0);
  }
  public String getName() { return "Sequencer"; }



  void activateClip(int row, int col) {
    clipButtons[activeClipIndex].setColor(clipBGColor);
    if (col >= 0) {
      activeClipIndex = row*4 + col;
    }
    clips.triggerOnActive(row, col);
  }
  void setActiveSequence(int sequenceIndex) {
    if (sequenceIndex >=0 && sequenceIndex < sequences.size()) {
      activeSequence = sequences.get(sequenceIndex);
      activeSequenceIndex = sequenceIndex;
    }
  }
  void loadSequences() { 
    File path = new File(sketchPath("sequences.json"));
    if(path.exists()) {
      serializer.load(path.getAbsolutePath(), sequences);
    }
  }
  void saveSequences() { 
    String path = sketchPath("sequences.json");
    try {
      serializer.save(path, sequences);
    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  boolean playPages = false;


  public void attach() {
    bindButtons();
    //setColors();

    bindSliderToOSCAction("A / B",        "ab");
    bindSliderToOSCAction("Master Level", "master");
    bindButtonToOSCAction("Tap Tempo",    "tap");
    bindButtonToOSCAction("Nudge -",      "nudge-");

    for(int i=0; i<8; ++i) {
      int layerNumber = i+1;
      bindKnobToOSCAction("Track Knob "+layerNumber, "comp"+i);
      for(int k=0; k<8; ++k) {
        bindKnobToOSCAction("Device "+layerNumber+" Control "+(k+1), "layer"+i+"_"+k);
      }
    }


    // Toggle activating either different
    bindButton("Sends", new NoteOnCallback() {
      public void noteOn(MidiButton button) {
        changeSequence = true;
        updateSequencePaletteButtons();
      }
    }, new NoteOffCallback() {
      public void noteOff(MidiButton button) { 
        changeSequence = false;
        updateSequencePaletteButtons();
      }
    });


    bindButton("Play", new NoteOnCallback() {
      public void noteOn(MidiButton button) {
        playPages = true;
      }
    }, new NoteOffCallback() {
      public void noteOff(MidiButton button) { 
        playPages = false;
      }
    });

    for(int i=0; i<8; ++i) {
      int number = i+1;
      EnableLayerSequenceHandler activatorHandler = new EnableLayerSequenceHandler(i);
      ClipsSoloHandler           soloHandler      = new ClipsSoloHandler(i);
      ClipsBlankHandler          blankHandler     = new ClipsBlankHandler(i);

      bindButton("Activator " + number, activatorHandler, activatorHandler);
      bindButton("Solo "      + number, soloHandler,      soloHandler);
      bindButton("Record "    + number, blankHandler,     blankHandler);

      bindSlider("Level "     + number, new ClipsChangeOpacityHandler(i));
    }

    // Bind sequence/palette handler buttons
    for(int i=0; i<8; ++i) {
      ActiveSequencePaletteHandler handler = new ActiveSequencePaletteHandler(i);
      bindButton("Clip Stop " + (i+1), handler, handler);
    }

    // Bind bank handler buttons
    for(int i=0; i<5; ++i) {
      ActiveBankHandler handler = new ActiveBankHandler(i);
      bindButton("Scene Launch " + (i+1), handler, handler);
    }

    beatCounter = (BeatCounterContext)getContext("BeatCounter");
  }

  
  public void update() {
    sequenceButtons[lastBeatIndex].setColor(seqBGColor);

    for(int i=0; i<16; ++i) {
      ClipEvent clipEvent = activeSequence.getClip(i + activePage*16);
      if(clipEvent != null) {
        if(clipEvent.clips.contains(activeClipIndex)) {
          sequenceButtons[i].setColor(seqActiveColor);
        } else {
          sequenceButtons[i].setColor(seqBGColor);
        }
      }
    }




    int beatIndex = beatCounter.getBeatIndex(4);
    sequenceButtons[beatIndex].setColor(seqCurrentBeatColor);

    if (beatIndex != lastBeatIndex) {
      ClipEvent lastClipEvents = activeSequence.getClip(lastBeatIndex + activePage*16);

      if (playPages && beatIndex == 0) {
        activePage += 1;
        activePage %= activeSequence.getPageCount();
        updatePageColors();
      }

      ClipEvent clipEvent      = activeSequence.getClip(beatIndex + activePage*16);

      for(int i=0; i<16; ++i) {
        clipButtons[i].setColor(i == activeClipIndex? clipActiveColor : clipBGColor);
      }

      // Disable any previously active clips that are not active any longer
      if(lastClipEvents != null) {
        for(Integer clipIndex : lastClipEvents.clips) {
          if (!clipEvent.clips.contains(clipIndex)) {
            int row = clipIndex / 4;
            clips.triggerOnActive(row, -1);
          }
        }
      } 


      // Activate all new clips (redundant ones are handled by dirty flags)
      if(clipEvent != null) {
        for(Integer clipIndex : clipEvent.clips) {
          int row = clipIndex / 4;
          int col = clipIndex % 4;
          clips.triggerOnActive(row, col);
          clipButtons[clipIndex].setColor(clipHighlightColor);
        }
      }

    }

    lastBeatIndex = beatIndex;

    // Save any changes to sequences every 120 frames
    if (frameCount % 120 == 0 && sequenceChanged) {
      saveSequences();
      sequenceChanged = false;
    }
  }

  void bindButtons() {
    for(int i=0; i<8; ++i) {
      PageButtonHandler handler = new PageButtonHandler(i);
      MidiButton button = bindButton("["+(i+1)+",1]", handler, handler);
      button.setColor(pageBGColor);
      pageButtons[i] = button;
    }
    for(int y=0; y<4; ++y) {
      for(int x=0; x<4; ++x) {
        MidiButton clipButton     = controller.getButtonNamed("["+(x+1)+","+(y+2)+"]");
        MidiButton sequenceButton = controller.getButtonNamed("["+(x+5)+","+(y+2)+"]");

        ClipButtonHandler clipHandler = new ClipButtonHandler(y,x); // row, col
        clipButton.addNoteOnCallback(clipHandler);
        clipButton.addNoteOffCallback(clipHandler);
        clipButton.setColor(clipBGColor);
        clipButtons[x+y*4] = clipButton;

        SequenceButtonHandler sequenceHandler = new SequenceButtonHandler(x+y*4);
        sequenceButton.addNoteOnCallback(sequenceHandler);
        sequenceButton.addNoteOffCallback(sequenceHandler);
        sequenceButton.setColor(seqBGColor);
        sequenceButtons[x+y*4] = sequenceButton;
      }
    }
  }


  // TEST CODE
  void setColors() {
    int i=0;
    for(int r=1; r<=5; ++r) {
      for(int c=1; c<=8; ++c) {
        controller.getButtonNamed("["+c+","+r+"]").setColor(i++);
      }
    }
  }
}