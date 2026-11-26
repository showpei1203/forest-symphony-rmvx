# RGSS2/Ruby 1.8 compatible test-only hook, inserted immediately before Main.
# Must never be inserted into the owner's original Scripts.rvdata.
# No graphics, game objects, event execution, save loading, network or shell.
module FS_BOOT_CAPTURE_PROBE
  TABLE_NAMES = %w[Actors Classes Skills Items Weapons Armors Enemies States Troops System Animations CommonEvents]
  @completed_apply = 0
  def self.record_apply
    @completed_apply += 1
  end
  def self.capture_root
    root = ENV["FS_VX_CAPTURE_ROOT"].to_s
    nonce = ENV["FS_VX_CAPTURE_NONCE"].to_s
    raise "capture root missing" if root.empty? || File.expand_path(root).downcase != File.expand_path(Dir.pwd).downcase
    raise "capture nonce invalid" unless nonce =~ /\A[0-9a-f]{32}\z/
    dir = File.join(root, "FS_BOOT_CAPTURE")
    raise "capture directory missing" unless File.directory?(dir)
    marker = File.join(dir, "SCOPE.txt")
    raise "capture marker mismatch" unless File.open(marker, "rb") { |f| f.read } == "FS_VX_CAPTURE_V1\n" + nonce + "\n"
    dir
  end
  def self.write_new(dir, name, data)
    target = File.join(dir, name)
    flags = File::WRONLY | File::CREAT | File::EXCL
    flags |= File::BINARY if defined?(File::BINARY)
    File.open(target, flags) { |f| f.write(data) }
  end
  def self.capture
    dir = capture_root
    raise "not exactly one completed original apply_all" unless @completed_apply == 1
    raise "MasterSetup handshake missing" unless FS_DB_AUTOSET.authority_ready?
    raise "unexpected authority" unless FS_DB_AUTOSET.authority_source.to_s == "FS_MASTER_SETUP"
    raise "unexpected AutoSetup version" unless $fs_db_autoset_version.to_s == FS_DB_AUTOSET::VERSION.to_s
    tables = [$data_actors, $data_classes, $data_skills, $data_items, $data_weapons,
      $data_armors, $data_enemies, $data_states, $data_troops, $data_system,
      $data_animations, $data_common_events]
    counts = []
    tables.each_with_index do |table, i|
      if TABLE_NAMES[i] == "System"
        raise "missing system" unless table && table.respond_to?(:party_members)
        counts << 1
      else
        raise "invalid table " + TABLE_NAMES[i] unless table.is_a?(Array) && table.size > 1 && table[0] == nil
        table.each_with_index do |row, index|
          next if row == nil
          raise "invalid ID " + TABLE_NAMES[i] unless row.respond_to?(:id) && row.id == index
        end
        counts << table.compact.size
      end
    end
    # Validate every table before writing; exclusive creates and final commit
    # marker prevent a partially captured bundle from being considered complete.
    TABLE_NAMES.each do |name|
      raise "capture target exists" if File.exist?(File.join(dir, name + ".rvdata"))
    end
    raise "capture completion already exists" if File.exist?(File.join(dir, "COMPLETE.tsv"))
    tables.each_with_index do |table, i|
      write_new(dir, TABLE_NAMES[i] + ".rvdata", Marshal.dump(table))
    end
    lines = ["schema\tfs-vx-capture-v1", "stage\tpost_Scene_Title.load_database",
      "apply_completed\t1", "authority_source\tFS_MASTER_SETUP",
      "autoset_version\t" + FS_DB_AUTOSET::VERSION.to_s,
      "ruby_version\t" + RUBY_VERSION.to_s, "nonce\t" + ENV["FS_VX_CAPTURE_NONCE"].to_s]
    TABLE_NAMES.each_with_index { |name, i| lines << "count_" + name + "\t" + counts[i].to_s }
    lines << "party\t" + $data_system.party_members.join(",")
    write_new(dir, "COMPLETE.tsv", lines.join("\n") + "\n")
  end
end
# Capture only after the actual final title database loader returns.
# This records completion of the effective AutoSetup method, not just its call.
class << FS_DB_AUTOSET
  alias fs_capture_original_apply_all apply_all
  def apply_all
    result = fs_capture_original_apply_all
    FS_BOOT_CAPTURE_PROBE.record_apply
    result
  end
end
class Scene_Title
  alias fs_capture_original_load_database load_database
  def load_database
    result = fs_capture_original_load_database
    FS_BOOT_CAPTURE_PROBE.capture
    exit
    result
  end
end
