

public class ClipPalleteRowLayer {
  int         layer;
  int         start;
  String      name;

  OSCAction[] connectCol;
  OSCAction   setLayerOpacity;

  int         lastActive = -1;
  boolean     wasOn = false;
  float       lastOpacity = 0;

  public void setDirty() {
    lastOpacity = 0.f;
    lastActive = -1;
    wasOn = false;
  }

  public ClipPalleteRowLayer(JSONObject rowLayer) {
    layer = rowLayer.getInt("layer");
    start = rowLayer.getInt("start");
    name  = rowLayer.getString("name");

    connectCol = new OSCAction[4];
    for(int i=0; i<connectCol.length; ++i) {
      int clip = start + i;
      connectCol[i] = oscConfig.newAction("arena:/layer"+layer+"/clip"+clip+"/connect", 1);
    }

    setLayerOpacity = oscConfig.newAction("arena:/layer"+layer+"/video/opacity/values", 1.0);
  }

  public void trigger(int col, float layerOpacity) {
    if (col == -1) {
      // Only send the layer off message if this layer was not alreday off
      if (wasOn) {
        setLayerOpacity.sendFloat(0.0);
        wasOn = false;
      }
    } else {
      // Only trigger the clip if it was not the last active clip on this layer
      if (col != lastActive) {
        if (layerOpacity > 0.01f) {
          connectCol[col].send();
        }
        lastActive = col;
      }
      // Only send the layer on message if this layer was not already on
      if (!wasOn || lastOpacity != layerOpacity) {
        setLayerOpacity.sendFloat(layerOpacity);
        lastOpacity = layerOpacity;
        wasOn = true;
      }
    }
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
  public void trigger(int col, float opacity) {
    for(ClipPalleteRowLayer layer : layers)
      layer.trigger(col, opacity);
  }
  public void setDirty() {
    for(ClipPalleteRowLayer layer : layers)
      layer.setDirty();
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

  public void trigger(int row, int col, float opacity) {
    rows[row].trigger(col, opacity);
  }

  public void setDirty() {
    for(int i=0; i<rows.length; ++i) {
      rows[i].setDirty();
    }
  }

}

public class ClipPalletes {
  int activePalette = 0;
  List<ClipPallete> palettes = new ArrayList<ClipPallete>();
  float[]           opacity  = new float[4];


  public ClipPalletes(String filePath) {
    JSONObject root     = loadJSONObject(filePath);
    JSONArray  palettes = root.getJSONArray("clip-palettes");

    for (int i=0, count=palettes.size(); i<count; ++i) {
      JSONObject palette = palettes.getJSONObject(i);
      this.palettes.add(new ClipPallete(palette));
    }
  }

  public int getActivePaletteIndex() {
    return activePalette;
  }
  // 8 palettes per bank
  public int getBankCount() {
    return (int)ceil(palettes.size() / 8.0);
  }

  public void setActivePalette(int paletteIndex) {
    if(paletteIndex >= 0 && paletteIndex < palettes.size()) {
      activePalette = paletteIndex;

      ClipPallete palette = palettes.get(activePalette);
      palette.setDirty();
    }
  }


  int[] getLayersForRow(int row) {
    if(activePalette >= 0 && activePalette < palettes.size()) {
      ClipPallete palette = palettes.get(activePalette);
      return palette.getLayersForRow(row);
    }
    return new int[0];
  }


  public void setOpacity(int row, float value) {
    opacity[row] = value;
  }
  public void triggerOnActive(int row, int col) {
    if(activePalette >= 0 && activePalette < palettes.size()) {
      ClipPallete palette = palettes.get(activePalette);
      palette.trigger(row, col, opacity[row]);
    }
  }
}