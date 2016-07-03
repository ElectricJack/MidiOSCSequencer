

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


  protected MidiButton bindButtonToOSCAction(String buttonName, String oscAction) {
    return bindButton(buttonName, new OSCNoteOnCallback(oscAction));
  }
  protected MidiButton bindButtonToOSCAction(String buttonName, String oscActionOn, String oscActionOff) {
    return bindButton(buttonName, new OSCNoteOnCallback(oscActionOn), new OSCNoteOffCallback(oscActionOff));
  }
  protected MidiSlider bindSliderToOSCAction(String sliderName, String oscAction) {
    return bindSlider(sliderName, new OSCSliderCallback(oscAction));
  }
  protected MidiKnob bindKnobToOSCAction(String knobName, String oscAction) {
    return bindKnob(knobName, new OSCKnobCallback(oscAction));
  }
  protected MidiSlider bindSlider(String sliderName, SliderCallback callback) {
    MidiSlider slider = controller.getSliderNamed(sliderName);
    if (slider != null) {
      slider.addChangeCallback(callback);
    }
    return slider;
  }
  protected MidiKnob bindKnob(String knobName, KnobCallback callback) {
    MidiKnob knob = controller.getKnobNamed(knobName);
    if (knob != null) {
      knob.addChangeCallback(callback);
    }
    return knob;
  }
  protected MidiButton bindButton(String buttonName, NoteOnCallback callbackOn) {
    return bindButton(buttonName, callbackOn, null);
  }
  protected MidiButton bindButton(String buttonName, NoteOnCallback callbackOn, NoteOffCallback callbackOff) {
    MidiButton button = controller.getButtonNamed(buttonName);
    if (button != null) {
      button.addNoteOnCallback(callbackOn);
      if (callbackOff != null) {
        button.addNoteOffCallback(callbackOff);
      }
    }
    return button;
  }

}