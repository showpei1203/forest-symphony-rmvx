#!/usr/bin/env ruby
# Build a test-only Scripts.rvdata in a NEW isolated staging root.
# Never changes input, never runs any source script, never creates owner PC
# workspace automatically. Ruby stdlib only; exact original archive pin.
require 'digest'
require 'zlib'
require 'fileutils'
module FSVXCaptureStage
  RAW_SHA = 'd398178135c5b41622b0e6da763d58af1fbf770c9d24a360a23508800015809a'
  ORIGINAL_COUNT = 505
  MAIN_INDEX = 482
  MAIN_ID = 32270711
  PROBE_ID = 190702761
  def self.build(input, root, nonce, probe_path, expected_sha=RAW_SHA, count=ORIGINAL_COUNT, main_index=MAIN_INDEX)
    raise 'nonce invalid' unless nonce =~ /\A[0-9a-f]{32}\z/
    raise 'source not regular file' unless File.file?(input) && !File.symlink?(input)
    input = File.realpath(input)
    root = File.expand_path(root)
    raise 'staging directory must be new' if File.exist?(root) || File.symlink?(root)
    raise 'staging cannot be inside source project' if (root.downcase + '/').start_with?(File.dirname(File.dirname(input)).downcase + '/')
    raise 'staging parent must exist' unless File.directory?(File.dirname(root))
    raw = File.binread(input)
    raise 'source SHA mismatch' unless Digest::SHA256.hexdigest(raw)==expected_sha
    raise 'source size invalid' unless raw.bytesize.between?(10,32*1024*1024)
    scripts=Marshal.load(raw) # exact SHA-pinned trusted owner script table only
    raise 'unexpected original script table' unless scripts.is_a?(Array) && scripts.size==count
    scripts.each do |row|
      raise 'invalid script row' unless row.is_a?(Array) && row.size==3 && row[0].is_a?(Integer) && row[1].is_a?(String) && row[2].is_a?(String)
    end
    main=scripts.fetch(main_index)
    raise 'Main identity mismatch' unless main[0]==MAIN_ID && main[1]=='Main'
    raise 'probe ID collision' if scripts.any?{|row| row[0]==PROBE_ID}
    probe=File.binread(probe_path)
    raise 'probe missing or oversized' unless probe.bytesize.between?(100,16384) && probe.include?('FS_BOOT_CAPTURE_PROBE')
    inserted=scripts.dup
    inserted.insert(main_index,[PROBE_ID,'FS_BOOT_CAPTURE_PROBE',Zlib::Deflate.deflate(probe)])
    raise 'original script rows changed' unless inserted.reject{|row|row[0]==PROBE_ID}==scripts
    payload=Marshal.dump(inserted)
    Dir.mkdir(root)
    Dir.mkdir(File.join(root,'Data'))
    Dir.mkdir(File.join(root,'FS_BOOT_CAPTURE'))
    File.open(File.join(root,'Data','Scripts.rvdata'),'wbx'){|f|f.write(payload)}
    File.open(File.join(root,'FS_BOOT_CAPTURE','SCOPE.txt'),'wbx'){|f|f.write("FS_VX_CAPTURE_V1\n"+nonce+"\n")}
    raise 'source changed' unless Digest::SHA256.file(input).hexdigest==expected_sha
    raise 'staged readback mismatch' unless Marshal.load(File.binread(File.join(root,'Data','Scripts.rvdata')))==inserted
    {original_sha:expected_sha,staged_sha:Digest::SHA256.hexdigest(payload),original_sections:count,inserted_sections:inserted.size,main_index:main_index}
  end
end
if __FILE__==$0
  abort 'Usage: stage original/Data/Scripts.rvdata NEW_ISOLATED_ROOT nonce' unless ARGV.size==3
  puts FSVXCaptureStage.build(ARGV[0],ARGV[1],ARGV[2],File.join(__dir__,'fs_vx_capture_probe.rb')).inspect
end
