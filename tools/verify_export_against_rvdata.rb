#!/usr/bin/env ruby
require 'zlib'
require 'json'
require 'digest'
require 'base64'

rvdata = ARGV[0] or abort 'usage: verify_export_against_rvdata.rb Scripts.rvdata [repo_root]'
root = ARGV[1] || File.expand_path('..', __dir__)
index = JSON.parse(File.read(File.join(root, 'authority', 'SCRIPT_INDEX.json')))
ary = Marshal.load(File.binread(rvdata))
abort "count mismatch expected=#{index['scripts_count']} actual=#{ary.length}" unless ary.length == index['scripts_count']
errors=[]
index['scripts'].each do |row|
  order=row['order']
  entry=ary[order]
  id,name,compressed=entry
  source=Zlib::Inflate.inflate(compressed)
  file=File.join(root,row['file'])
  errors << "order #{order}: script id #{id} != #{row['script_id']}" unless id == row['script_id']
  errors << "order #{order}: name bytes mismatch" unless Base64.strict_encode64(name.to_s.b) == row['script_name_base64']
  errors << "order #{order}: source hash mismatch vs index" unless Digest::SHA256.hexdigest(source) == row['source_sha256']
  errors << "order #{order}: exported file missing" unless File.file?(file)
  errors << "order #{order}: exported file content mismatch" if File.file?(file) && File.binread(file) != source
end
if errors.empty?
  puts "PASS scripts=#{ary.length} rvdata_sha256=#{Digest::SHA256.file(rvdata).hexdigest}"
  exit 0
else
  warn errors.join("\n")
  exit 1
end
