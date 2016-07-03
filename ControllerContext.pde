

public abstract class ControllerContext
{
  protected MidiController controller;

  public ControllerContext(MidiController controller) {
    this.controller = controller;
  }

  public abstract String getName();
  public abstract void attach();
  public void detach() {
    // Remove all attached callbacks
    //@TODO
  }

  public abstract void update();


  protected void bindButtonToOSCAction(String buttonName, String oscAction) {
    bindButton(buttonName, new OSCNoteOnCallback(oscAction));
  }

  protected void bindButtonToOSCAction(String buttonName, String oscActionOn, String oscActionOff) {
    bindButton(buttonName, new OSCNoteOnCallback(oscActionOn), new OSCNoteOffCallback(oscActionOff));
  }

  protected void bindSliderToOSCAction(String sliderName, String oscAction) {
    bindSlider(sliderName, new OSCSliderCallback(oscAction));
  }
  protected void bindKnobToOSCAction(String knobName, String oscAction) {
    bindKnob(knobName, new OSCKnobCallback(oscAction));
  }
  protected void bindSlider(String sliderName, SliderCallback callback) {
    MidiSlider slider = controller.getSliderNamed(sliderName);
    if (slider != null) {
      slider.addChangeCallback(callback);
    }
  }
  protected void bindKnob(String knobName, KnobCallback callback) {
    MidiKnob knob = controller.getKnobNamed(knobName);
    if (knob != null) {
      knob.addChangeCallback(callback);
    }
  }

  protected void bindButton(String buttonName, NoteOnCallback callbackOn) {
    bindButton(buttonName, callbackOn, null);
  }
  protected void bindButton(String buttonName, NoteOnCallback callbackOn, NoteOffCallback callbackOff) {
    MidiButton button = controller.getButtonNamed(buttonName);
    if (button != null) {
      button.addNoteOnCallback(callbackOn);
      if (callbackOff != null) {
        button.addNoteOffCallback(callbackOff);
      }
    }
  }

}