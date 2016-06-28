
// -------------------------------------------------------------------- //
/*void initSliders() {
  apc40.getSliderNamed("A / B").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("ab", t); }
  });
  
  apc40.getKnobNamed("Device 1 Control 1").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device1", t); }
  });
  apc40.getKnobNamed("Device 1 Control 2").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device2", t); }
  });
  apc40.getKnobNamed("Device 1 Control 3").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device3", t); }
  });
  apc40.getKnobNamed("Device 1 Control 4").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device4", t); }
  });
  apc40.getKnobNamed("Device 1 Control 5").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device5", t); }
  });
  apc40.getKnobNamed("Device 1 Control 6").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device6", t); }
  });
  apc40.getKnobNamed("Device 1 Control 7").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device7", t); }
  });
  apc40.getKnobNamed("Device 1 Control 8").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("device8", t); }
  });
  
  apc40.getKnobNamed("Track Knob 1").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track1", t); }
  });
  apc40.getKnobNamed("Track Knob 2").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track2", t); }
  });
  apc40.getKnobNamed("Track Knob 3").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track3", t); }
  });
  apc40.getKnobNamed("Track Knob 4").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track4", t); }
  });
  apc40.getKnobNamed("Track Knob 5").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track5", t); }
  });
  apc40.getKnobNamed("Track Knob 6").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track6", t); }
  });
  apc40.getKnobNamed("Track Knob 7").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track7", t); }
  });
  apc40.getKnobNamed("Track Knob 8").addChangeCallback(new KnobCallback() {
   public void change(MidiKnob knob, float t) { oscConfig.sendFader("track8", t);}
  });

  apc40.getSliderNamed("Level 1").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level1", t); }
  });
  apc40.getSliderNamed("Level 2").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level2", t); }
  });
  apc40.getSliderNamed("Level 3").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level3", t); }
  });
  apc40.getSliderNamed("Level 4").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level4", t); }
  });
  apc40.getSliderNamed("Level 5").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level5", t); }
  });
  apc40.getSliderNamed("Level 6").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level6", t); }
  });
  apc40.getSliderNamed("Level 7").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level7", t); }
  });
  apc40.getSliderNamed("Level 8").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("level8", t); }
  });
  apc40.getSliderNamed("Master Level").addChangeCallback(new SliderCallback() {
    public void change(MidiSlider slider, float t) { oscConfig.sendFader("master", t); }
  });
  
}*/
// -------------------------------------------------------------------- //
/*void initButtons() {
  apc40.getButtonNamed("Tap Tempo").addNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { oscConfig.sendButton("tap"); }
  });
  apc40.getButtonNamed("Nudge -").addNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { oscConfig.sendButton("nudge-"); }
  });
}*/

// -------------------------------------------------------------------- //
/*
void initEffectPages() {
  NoteOnCallback effectOnHandler = new NoteOnCallback() {
    public void noteOn(MidiButton button) {
      int effectIndex = effectIndexMap.get(button);
      println("send on! " + effectIndex);
      oscConfig.sendEffect(currentPage, effectIndex, true);
    }
  };
  NoteOffCallback effectOffHandler = new NoteOffCallback() {
    public void noteOff(MidiButton button) {
      int effectIndex = effectIndexMap.get(button);
      println("send off! " + effectIndex);
      oscConfig.sendEffect(currentPage, effectIndex, false);
    }
  };
  
  int clipIndex = 0;
  for (int c=0; c<8; ++c, ++clipIndex) {
    String name = "Activator "+(c+1);
    MidiButton button = apc40.getButtonNamed(name);
    if (button != null) {
      effectIndexMap.put(button, clipIndex);
      button.setNoteOnCallback(effectOnHandler);
      button.setNoteOffCallback(effectOffHandler);
    }
  }
  
  for (int c=0; c<8; ++c, ++clipIndex) {
    String name = "Solo / Cue "+(c+1);
    MidiButton button = apc40.getButtonNamed(name);
    if (button != null) {
      effectIndexMap.put(button, clipIndex);
      button.setNoteOnCallback(effectOnHandler);
      button.setNoteOffCallback(effectOffHandler);
    }
  }
  
  for (int c=0; c<8; ++c, ++clipIndex) {
    String name = "Record Arm "+(c+1);
    MidiButton button = apc40.getButtonNamed(name);
    if (button != null) {
      effectIndexMap.put(button, clipIndex);
      button.setNoteOnCallback(effectOnHandler);
      button.setNoteOffCallback(effectOffHandler);
    }
  }
}*/

/*
void initButtonPages() {
  NoteOnCallback leftHandler = new NoteOnCallback() {
    public void noteOn(MidiButton button) {
      int clipIndex = indexMap.get(button);
      oscConfig.sendClip(currentPage, clipIndex, shiftEnabled, 1);
      clearLastPageButtons();
      if (!shiftEnabled) {
        lastButtonLeft = button;
      }
    }
  };

  NoteOnCallback rightHandler = new NoteOnCallback() {
    public void noteOn(MidiButton button) {
      int clipIndex = indexMap.get(button);
      oscConfig.sendClip(currentPage, clipIndex, shiftEnabled, 1);
      clearLastPageButtons();
      if (!shiftEnabled) {
        lastButtonRight = button;
      }
    }
  };
  
  NoteOffCallback leftOffHandler = new NoteOffCallback() {
    public void noteOff(MidiButton button) {
      int clipIndex = indexMap.get(button);
      oscConfig.sendClip(currentPage, clipIndex, shiftEnabled, 0);
    }
  };

  NoteOffCallback rightOffHandler = new NoteOffCallback() {
    public void noteOff(MidiButton button) {
      int clipIndex = indexMap.get(button);
      oscConfig.sendClip(currentPage, clipIndex, shiftEnabled, 0);
    }
  };
  

  // Left side
  int clipIndex = 0;
  for (int r=0; r<5; ++r) {
    for (int c=0; c<4; ++c, ++clipIndex) {
      String name = "["+(c+1)+","+(r+1)+"]";
      MidiButton button = apc40.getButtonNamed(name);
      if (button != null) {
        indexMap.put(button, clipIndex);
        button.setNoteOnCallback(leftHandler);
        button.setNoteOffCallback(leftOffHandler);
      }
    }
  }

  // Right side
  for (int r=0; r<5; ++r) {
    for (int c=0; c<4; ++c, ++clipIndex) {
      String name = "["+(c+5)+","+(r+1)+"]";
      MidiButton button = apc40.getButtonNamed(name);
      if (button != null) {
        indexMap.put(button, clipIndex);
        button.setNoteOnCallback(rightHandler);
        button.setNoteOffCallback(rightOffHandler);
      }
    }
  }
  
  MidiButton shiftButton = apc40.getButtonNamed("Shift");
  shiftButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { shiftEnabled = true; }
  });
  shiftButton.setNoteOffCallback(new NoteOffCallback() {
    public void noteOff(MidiButton button) { shiftEnabled = false; }
  });
  

  MidiButton pageButton;
  pageButton = apc40.getButtonNamed("Clip Stop 1");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 0; }
  });
  pageButtons.add(pageButton);
  
  pageButton = apc40.getButtonNamed("Clip Stop 2");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 1; }
  });
  pageButtons.add(pageButton);
  
  pageButton = apc40.getButtonNamed("Clip Stop 3");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 2; }
  });
  pageButtons.add(pageButton);
  
  pageButton = apc40.getButtonNamed("Clip Stop 4");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 3; }
  });
  pageButtons.add(pageButton);
  
  pageButton = apc40.getButtonNamed("Clip Stop 5");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 4; }
  });
  pageButtons.add(pageButton);
  
  pageButton = apc40.getButtonNamed("Clip Stop 6");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 5; }
  });
  pageButtons.add(pageButton);

  pageButton = apc40.getButtonNamed("Clip Stop 7");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 6; }
  });
  pageButtons.add(pageButton);
  
  pageButton = apc40.getButtonNamed("Clip Stop 8");
  pageButton.setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { currentPage = 7; }
  });
  pageButtons.add(pageButton);
}
*/


// -------------------------------------------------------------------- //
/*void initFaderFeedback() {
  // Init out button columns
  for (int i=0; i<8; ++i) {
    List<MidiButton> col = new ArrayList<MidiButton>();
    apc40.getButtonsAtX(0.5 + i, col);
    buttonCols.add(col);
    MidiSlider slider = apc40.getControlNamed("Level "+(i+1)).asSlider();
    slider.index = i;
    faderSliders.add(slider);
    slider.addChangeCallback(new SliderCallback() {
      public void change(MidiSlider slider, float t) {
        updateCol( buttonCols.get(slider.index), t );
      }
    });
  }
}*/
// -------------------------------------------------------------------- //
/*
void initBeatCounter() {
  apc40.getButtonNamed("Tap Tempo").setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { 
      beatCounter.tap();
    }
  });

  apc40.getButtonNamed("Nudge -").setNoteOnCallback(new NoteOnCallback() {
    public void noteOn(MidiButton button) { 
      beatCounter.tapFirst();
    }
  });

  beatButtons.add(apc40.getButtonNamed("Pan"));
  beatButtons.add(apc40.getButtonNamed("Send A"));
  beatButtons.add(apc40.getButtonNamed("Send B"));
  beatButtons.add(apc40.getButtonNamed("Send C"));
}*/