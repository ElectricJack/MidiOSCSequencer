

public class ClipPalleteRowLayer {
  int         layer;
  int         start;
  String      name;
  OSCAction[] connectCol;

  public ClipPalleteRowLayer(JSONObject rowLayer) {
    layer = rowLayer.getInt("layer");
    start = rowLayer.getInt("start");
    name  = rowLayer.getString("name");

    connectCol = new OSCAction[4];
    for(int i=0; i<connectCol.length; ++i) {
      int clip = start + i;
      connectCol[i] = oscConfig.newAction("arena:/layer"+layer+"/clip"+clip+"/connect", 1);
    }
  }
  public void trigger(int col) {
    connectCol[col].send();
  }
}

public class ClipPalleteRow {
  public List<ClipPalleteRowLayer> layers = new ArrayList<ClipPalleteRowLayer>();
  public ClipPalleteRow(JSONArray row) {
    for (int i=0, count=row.size(); i<count; ++i) {
      JSONObject rowLayer = row.getJSONObject(i);
      layers.add(new ClipPalleteRowLayer(rowLayer));
    }
  }
  public void trigger(int col) {
    for(ClipPalleteRowLayer layer : layers)
      layer.trigger(col);
  }
}


public class ClipPallete {
  private String           paletteType;
  private int              rowCount;
  private ClipPalleteRow[] rows;

  public ClipPallete(JSONObject palette) {
    paletteType = palette.getString("type");
    rowCount    = palette.getInt("rows");
    rows        = new ClipPalleteRow[rowCount];
    for(int i=0; i<rowCount; ++i) {
      JSONArray row = palette.getJSONArray("row"+i);
      rows[i] = new ClipPalleteRow(row);
    }
  }

  int[] getLayersForRow(int row) {
    int[] layers = new int[rows[row].layers.size()];
    for(int i=0; i<layers.length; ++i) {
      layers[i] = rows[row].layers.get(i).layer;
    }
    return layers;
  }

  public void trigger(int row, int col) {
    rows[row].trigger(col);
  }

  public void attach(MidiController controller) {
    // for(int row=0; row<4; ++row) {
    //   int[] layers = getLayersForRow(row);
    //   controller.add()
    // }
  }
}

public class ClipPalletes {
  int activePalette = 0;
  List<ClipPallete> palettes = new ArrayList<ClipPallete>();

  public ClipPalletes(PApplet parent, String filePath) {
    JSONObject root     = loadJSONObject(filePath);
    JSONArray  palettes = root.getJSONArray("clip-palettes");

    for (int i=0, count=palettes.size(); i<count; ++i) {
      JSONObject palette = palettes.getJSONObject(i);
      this.palettes.add(new ClipPallete(palette));
    }
  }

  int[] getLayersForRow(int row) {
    if(activePalette >= 0 && activePalette < palettes.size()) {
      ClipPallete palette = palettes.get(activePalette);
      return palette.getLayersForRow(row);
    }
    return new int[0];
  }

  public void attach(MidiController controller) {
    if(activePalette >= 0 && activePalette < palettes.size()) {
      palettes.get(activePalette).attach(controller);
    }
  }



  public void triggerOnActive(int row, int col) {
    if(activePalette >= 0 && activePalette < palettes.size()) {
      ClipPallete palette = palettes.get(activePalette);
      palette.trigger(row,col);
    }
  }
}






