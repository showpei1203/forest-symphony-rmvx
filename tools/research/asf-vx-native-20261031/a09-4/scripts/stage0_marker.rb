module ASF_A094
  def self.log(str)
    File.open("ASF_A094_DIAGNOSTIC.log","ab") {|f| f.write(str.to_s+"\n")}
  end
end
ASF_A094.log("A094_SCRIPT_EVALUATED")
class Scene_Title
  alias asf_a094_original_update update
  def update
    unless @asf_a094_title_marker
      @asf_a094_title_marker=true
      ASF_A094.log("A094_TITLE_UPDATE_ENTERED")
    end
    asf_a094_original_update
  end
end
class Spriteset_Map
  alias asf_a094_source_update update
  def update
    asf_a094_source_update
    @asf_a094_frames = 0 if @asf_a094_frames==nil
    @asf_a094_frames += 1
    if @asf_a094_frames == 35
      ASF_A094.log("A094_MAP_FRAME_35")
    end
  end
end