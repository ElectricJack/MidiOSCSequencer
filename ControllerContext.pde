

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


  protected void bindButtonToOSCAction(String controllerButton, String oscAction) {
    MidiButton button = controller.getButtonNamed(controllerButton);
    if (button != null) {
      button.addNoteOnCallback(new OSCNoteOnCallback(oscAction));
    }
  }

  protected void bindSliderToOSCAction(String controllerSlider, String oscAction) {
    MidiSlider slider = controller.getSliderNamed(controllerSlider);
    if (slider != null) {
      slider.addChangeCallback(new OSCSliderCallback(oscAction));
    }
  }

  protected void bindKnobToOSCAction(String controllerKnob, String oscAction) {
    MidiKnob knob = controller.getKnobNamed(controllerKnob);
    if (knob != null) {
      knob.addChangeCallback(new OSCKnobCallback(oscAction));
    }
  }
}