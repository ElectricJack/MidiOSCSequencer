
class Event {

}

class Sequence {
  int         beatsPerMeasure = 8;
  int         pageCount = 1;
  List<Event> events = new ArrayList<Event>();
}


public class SequencerContext extends ControllerContext
{
  final int pageBGColor     = 32;
  final int pageActiveColor = 25;
  final int pageExistColor  = 37;

  final int clipBGColor      = 4;
  final int clipActiveColor  = 7;
  final int seqBGColor       = 0;


  class PageButtonHandler implements NoteOnCallback, NoteOffCallback {
    public PageButtonHandler() {

    }
    void noteOn(MidiButton button) {}
    void noteOff(MidiButton button) {}
  }
  class ClipButtonHandler implements NoteOnCallback, NoteOffCallback {
    public ClipButtonHandler() {

    }
    void noteOn(MidiButton button) { }
    void noteOff(MidiButton button) { }
  }
  class SequenceButtonHandler implements NoteOnCallback, NoteOffCallback {
    public SequenceButtonHandler() {
      
    }
    void noteOn(MidiButton button) { }
    void noteOff(MidiButton button) { }
  }


  public        SequencerContext(MidiController controller) { super(controller); }
  public String getName()                                   { return "Sequencer"; }



  int          activeClipIndex = 0;
  MidiButton[] pageButtons     = new MidiButton[8];
  MidiButton[] clipButtons     = new MidiButton[16];
  MidiButton[] sequenceButtons = new MidiButton[16];


  public void attach() {
    bindButtons();
    //setColors();
  }

  public void update() {
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

        ClipButtonHandler clipHandler = new ClipButtonHandler();
        clipButton.addNoteOnCallback(clipHandler);
        clipButton.addNoteOffCallback(clipHandler);
        clipButton.setColor(clipBGColor);
        clipButtons[x+y*4] = clipButton;

        SequenceButtonHandler sequenceHandler = new SequenceButtonHandler();
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