
public class ClipEvent {
  public int clipIndex = -1;
  public List<Integer> clips = new ArrayList<Integer>();
  //public ClipEvent() { }

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

public class FloatChannel {
  float[] values = new float[256];
}

public class Sequence {
  int                 beatsPerMeasure = 8;
  int                 pageCount       = 1;
  List<ClipEvent>     clipEvents      = new ArrayList<ClipEvent>();
  List<FloatChannel>  floatChannels   = new ArrayList<FloatChannel>();

  public Sequence() {
    resizeClips();
  }

  public boolean toggleClip(int page, int beatIndex, int clipIndex) {
    int index = page*16 + beatIndex;
    if(index >= 0 && index < clipEvents.size()) {
      ClipEvent clipEvent = clipEvents.get(index);
      return clipEvent.toggleClip(clipIndex);
    }
    return false;
  }

  public void resizeClips() {
    int eventCount = 16*pageCount;
    for(int i=clipEvents.size(); i<eventCount; ++i) {
      clipEvents.add(new ClipEvent());
    }
  }
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


  int          activePage      = 0;
  Sequence     activeSequence  = new Sequence();
  int          activeClipIndex = 0;

  MidiButton[] pageButtons     = new MidiButton[8];
  MidiButton[] clipButtons     = new MidiButton[16];
  MidiButton[] sequenceButtons = new MidiButton[16];




  class PageButtonHandler implements NoteOnCallback, NoteOffCallback {
    public PageButtonHandler() {
      
    }
    void noteOn(MidiButton button) {}
    void noteOff(MidiButton button) {}
  }
  class ClipButtonHandler implements NoteOnCallback, NoteOffCallback {
    int row, col;
    public ClipButtonHandler(int row, int col) {
      this.row = row;
      this.col = col;
    }
    void noteOn(MidiButton button) {
      activateClip(row, col);
      button.setColor(clipHighlightColor);
    }
    void noteOff(MidiButton button) {
      button.setColor(clipActiveColor);
    }
  }
  class SequenceButtonHandler implements NoteOnCallback, NoteOffCallback {
    int     beatIndex;
    boolean active;
    public SequenceButtonHandler(int beatIndex) {
      this.beatIndex = beatIndex;
    }
    void noteOn(MidiButton button) {
      active = activeSequence.toggleClip(activePage, beatIndex, activeClipIndex);
      updateColor(button);
    }
    void noteOff(MidiButton button) {
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


  public        SequencerContext(MidiController controller) { super(controller); }
  public String getName()                                   { return "Sequencer"; }



  
  void activateClip(int row, int col) {
    clipButtons[activeClipIndex].setColor(clipBGColor);
    activeClipIndex = row*4 + col;
    clips.triggerOnActive(row, col);
  }



  BeatCounterContext beatCounter;

  public void attach() {
    bindButtons();
    //setColors();

    bindSliderToOSCAction("A / B",  "ab");
    bindSliderToOSCAction("Master", "master");
    bindButtonToOSCAction("Tap Tempo", "tap");
    bindButtonToOSCAction("Nudge -",   "nudge-");

    beatCounter = (BeatCounterContext)getContext("BeatCounter");

    clips.attach(controller);
  }

  int lastBeatIndex = 0;
  public void update() {
    sequenceButtons[lastBeatIndex].setColor(seqBGColor);

    for(int i=0; i<16; ++i) {
      ClipEvent clipEvent = activeSequence.clipEvents.get(i + activePage*16);
      if(clipEvent.clips.contains(activeClipIndex)) {
        sequenceButtons[i].setColor(seqActiveColor);
      } else {
        sequenceButtons[i].setColor(seqBGColor);
      }
    }
    //println("");

    int beatIndex = beatCounter.getBeatIndex(4);
    sequenceButtons[beatIndex].setColor(seqCurrentBeatColor);

    if (beatIndex != lastBeatIndex) {
      ClipEvent clipEvent = activeSequence.clipEvents.get(beatIndex + activePage*16);
      for(Integer clipIndex : clipEvent.clips) {
        int row = clipIndex / 4;
        int col = clipIndex % 4;
        clips.triggerOnActive(row, col);
      }
    }

    lastBeatIndex = beatIndex;
  }

  void bindButtons() {
    for(int i=1; i<=8; ++i) {
      MidiButton button = controller.getButtonNamed("["+i+",1]");
      button.setColor(pageBGColor);
      pageButtons[i-1] = button;
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