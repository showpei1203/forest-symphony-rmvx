# FS A28 | EXPERIMENTAL RGSS2 / RPG Maker VX per-character PAR adapter
# Safety: opt-in only, disabled by default. DO NOT insert into sealed FS project.
# Place AFTER default Sprite_Character and BEFORE Main, only in an isolated VX copy.
# Screen/foot coordinates must be calibrated against genuine FS Scripts.rvdata.
# Never stack this with an all-on PAR for the same world source object.
# Uses only Ruby 1.8 syntax and documented RGSS2 Bitmap/Sprite APIs.
module FS_A28_Occlusion
  ENABLED = false
  MAP_ID = 0  # FAIL CLOSED until the actual target FS map ID is verified.
  # Original Switch203 meaning is unknown here; this adapter does NOT redefine it.
  # Unique mask objects, each cropped to its actual nonempty bounding box.
  # [name, x, y, width, height, far_foot_y, near_foot_y, actor_x_min, actor_x_max]
  # far and near are manually calibrated SCREEN-ROW DEPTH HINTS, not 3D truth.
  OBJECTS = [
    ["FS_A28_LEFT_TREE", 75, 413, 360, 138, 440, 575, 75, 435],
    ["FS_A28_RIGHT_TREE", 1039, 645, 241, 283, 700, 927, 1039, 1280],
    ["FS_A28_BRIDGE_RAIL", 667, 582, 106, 72, 610, 641, 667, 773]
  ]

  def self.active?
    ENABLED && MAP_ID > 0 && $game_map != nil &&
      $game_map.map_id == MAP_ID
  end

  def self.check_geometry!
    OBJECTS.each do |o|
      raise 'FS_A28: malformed object' unless o.size == 9
      raise 'FS_A28: unsafe bbox' unless o[1] >= 0 && o[2] >= 0 && o[3] > 0 && o[4] > 0
      raise 'FS_A28: unsafe depth limits' unless o[5] <= o[6]
      raise 'FS_A28: unsafe x span' unless o[7] <= o[8]
    end
  end

  def self.paint!(dest, actor_bitmap, actor_rect, actor_world_x, actor_world_y,
                  actor_foot_y, source_provider)
    check_geometry!
    # Destination Bitmap width/height is exactly the actor frame cell size.
    # All mask-pixels are source-Master RGBA, in the original world coordinates.
    dest.clear
    ox = actor_world_x
    oy = actor_world_y
    OBJECTS.each do |o|
      name, x, y, w, h, far_y, near_y, x_min, x_max = o
      next if ox + dest.width <= x_min || ox >= x_max
      next if oy + dest.height <= y || oy >= y + h
      next if actor_foot_y >= near_y
      source = source_provider.call(name)
      next if source == nil
      raise 'FS_A28: source crop dimensions mismatch' unless source.width == w && source.height == h
      first_x = [ox, x, x_min].max
      last_x = [ox + dest.width, x + w, x_max].min
      first_y = [oy, y].max
      last_y = [oy + dest.height, y + h].min
      top = y
      bottom = y + h - 1
      den = [1, bottom - top].max
      first_y.upto(last_y - 1) do |wy|
        # Exact integer equivalent of A27's foot_y < linearly interpolated limit.
        next unless actor_foot_y * den < far_y * den + (near_y - far_y) * (wy - top)
        first_x.upto(last_x - 1) do |wx|
          lx = wx - ox
          ly = wy - oy
          next if actor_bitmap.get_pixel(actor_rect.x + lx, actor_rect.y + ly).alpha == 0
          color = source.get_pixel(wx - x, wy - y)
          next if color.alpha == 0
          dest.set_pixel(lx, ly, color)
        end
      end
    end
    dest
  end
end

if defined?(Sprite_Character)
  class Sprite_Character
    alias fs_a28_original_update update
    alias fs_a28_original_dispose dispose

    def update
      fs_a28_original_update
      fs_a28_occlusion_update
    end

    def fs_a28_occlusion_update
      unless FS_A28_Occlusion.active?
        @fs_a28_overlay.visible = false if @fs_a28_overlay != nil
        return
      end
      unless self.bitmap != nil && @character != nil && self.visible
        @fs_a28_overlay.visible = false if @fs_a28_overlay != nil
        return
      end
      if @character.respond_to?(:tile_id) && @character.tile_id.to_i > 0
        @fs_a28_overlay.visible = false if @fs_a28_overlay != nil
        return
      end
      rect = self.src_rect
      return if rect.width < 1 || rect.height < 1
      if @fs_a28_overlay == nil
        @fs_a28_overlay = Sprite.new(self.viewport)
      end
      if @fs_a28_overlay.bitmap == nil ||
          @fs_a28_overlay.bitmap.width != rect.width ||
          @fs_a28_overlay.bitmap.height != rect.height
        @fs_a28_overlay.bitmap.dispose if @fs_a28_overlay.bitmap != nil
        @fs_a28_overlay.bitmap = Bitmap.new(rect.width, rect.height)
        @fs_a28_key = nil
      end
      # VX map display_x/display_y and real_x/real_y are 1/256 tile units.
      # Sprite's x/y origin and current src_rect handle custom cell dimensions.
      scroll_x = ($game_map.display_x * 32) / 256
      scroll_y = ($game_map.display_y * 32) / 256
      wx = self.x - self.ox + scroll_x
      wy = self.y - self.oy + scroll_y
      foot_y = self.y - 1 + scroll_y
      key = [wx, wy, foot_y, rect.x, rect.y, rect.width, rect.height,
             self.bitmap.object_id]
      if key != @fs_a28_key
        painter = Proc.new { |name| Cache.parallax(name) }
        FS_A28_Occlusion.paint!(@fs_a28_overlay.bitmap, self.bitmap, rect,
                                wx, wy, foot_y, painter)
        @fs_a28_key = key
      end
      overlay = @fs_a28_overlay
      overlay.x = self.x
      overlay.y = self.y
      overlay.z = self.z + 1
      overlay.ox = self.ox
      overlay.oy = self.oy
      overlay.zoom_x = self.zoom_x
      overlay.zoom_y = self.zoom_y
      overlay.opacity = self.opacity
      overlay.visible = self.visible
      # IMPORTANT: no blanket PAR on top of character for these three objects.
    end

    def dispose
      if @fs_a28_overlay != nil
        @fs_a28_overlay.bitmap.dispose if @fs_a28_overlay.bitmap != nil
        @fs_a28_overlay.dispose
        @fs_a28_overlay = nil
      end
      fs_a28_original_dispose
    end
  end
end
