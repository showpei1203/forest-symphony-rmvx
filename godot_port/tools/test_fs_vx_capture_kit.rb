#!/usr/bin/env ruby
# Native Ruby synthetic test of injection, hook and failure behavior.
require 'tmpdir'
require 'digest'
require 'zlib'
require 'fileutils'
require 'rbconfig'
require_relative 'stage_fs_vx_capture'
PROBE=File.join(__dir__,'fs_vx_capture_probe.rb')
nonce='1234567890abcdef1234567890abcdef'
Dir.mktmpdir('fs-capture-test') do |base|
  src=File.join(base,'original','Data')
  FileUtils.mkdir_p(src)
  input=File.join(src,'Scripts.rvdata')
  rows=[[9,'before',Zlib::Deflate.deflate('before')],[FSVXCaptureStage::MAIN_ID,'Main',Zlib::Deflate.deflate('main')],[10,'after',Zlib::Deflate.deflate('after')]]
  File.binwrite(input,Marshal.dump(rows))
  digest=Digest::SHA256.file(input).hexdigest
  checks=0
  assert=lambda{|v,msg|raise msg unless v; checks+=1}
  root=File.join(base,'isolated')
  begin
    FSVXCaptureStage.build(input,root,nonce,PROBE,'0'*64,3,1);raise 'bad pin accepted'
  rescue RuntimeError=>e
    assert.call(e.message=='source SHA mismatch' && !File.exist?(root),'bad pin rejection')
  end
  begin
    FSVXCaptureStage.build(input,File.join(base,'original','test'),nonce,PROBE,digest,3,1);raise 'source nested accepted'
  rescue RuntimeError=>e
    assert.call(e.message.include?('inside source'),'source nested rejection')
  end
  result=FSVXCaptureStage.build(input,root,nonce,PROBE,digest,3,1)
  assert.call(result[:inserted_sections]==4 && Digest::SHA256.file(input).hexdigest==digest,'staging preserves source')
  staged=Marshal.load(File.binread(File.join(root,'Data','Scripts.rvdata')))
  assert.call(staged[2]==rows[1] && staged.reject{|r|r[0]==FSVXCaptureStage::PROBE_ID}==rows,'exact main and all sections preserved')
  begin
    FSVXCaptureStage.build(input,root,nonce,PROBE,digest,3,1);raise 'overwrite allowed'
  rescue RuntimeError=>e
    assert.call(e.message.include?('must be new'),'existing root rejected')
  end
  harness=<<'RUBY'
module RPG
  class Record
    attr_accessor :id
    def initialize(id); @id=id; end
  end
  class System
    attr_accessor :party_members
    def initialize; @party_members=[1]; end
  end
end
module FS_DB_AUTOSET
  VERSION="1.5.0"
  def self.authority_ready?; ENV["BAD_AUTH"]!="1"; end
  def self.authority_source; "FS_MASTER_SETUP"; end
  def self.apply_all
    $fs_db_autoset_version=VERSION
    $data_skills[1].instance_variable_set(:@mp_cost,18)
  end
end
class Scene_Title
  def load_database
    $data_actors=[nil,RPG::Record.new(1)]
    $data_classes=[nil,RPG::Record.new(1)]
    $data_skills=[nil,RPG::Record.new(1)]
    $data_items=[nil,RPG::Record.new(1)]
    $data_weapons=[nil,RPG::Record.new(1)]
    $data_armors=[nil,RPG::Record.new(1)]
    $data_enemies=[nil,RPG::Record.new(1)]
    $data_states=[nil,RPG::Record.new(1)]
    $data_troops=[nil,RPG::Record.new(1)]
    $data_animations=[nil,RPG::Record.new(1)]
    $data_common_events=[nil,RPG::Record.new(1)]
    $data_system=RPG::System.new
    FS_DB_AUTOSET.apply_all unless ENV["NO_APPLY"]=="1"
  end
end
load ENV.fetch("PROBE")
Scene_Title.new.load_database
raise "probe failed to exit before gameplay"
RUBY
  script=File.join(base,'synthetic.rb')
  File.write(script,harness)
  env={'FS_VX_CAPTURE_ROOT'=>root,'FS_VX_CAPTURE_NONCE'=>nonce,'PROBE'=>PROBE}
  assert.call(!system(env.merge('NO_APPLY'=>'1'),RbConfig.ruby,script,chdir:root,out:File::NULL,err:File::NULL),'missing apply rejected')
  assert.call(Dir.children(File.join(root,'FS_BOOT_CAPTURE'))==['SCOPE.txt'],'no partial writes on missing apply')
  assert.call(!system(env.merge('BAD_AUTH'=>'1'),RbConfig.ruby,script,chdir:root,out:File::NULL,err:File::NULL),'missing authority rejected')
  assert.call(!system(env.merge('FS_VX_CAPTURE_NONCE'=>'0'*32),RbConfig.ruby,script,chdir:root,out:File::NULL,err:File::NULL),'nonce rejected')
  assert.call(system(env,RbConfig.ruby,script,chdir:root),'capture executed')
  capture=File.join(root,'FS_BOOT_CAPTURE')
  assert.call(Dir.children(capture).size==14,'12 tables and markers')
  output=File.join(base,'converted')
  converter=File.join(__dir__,'decode_fs_vx_capture.py')
  assert.call(system('python3','-I','-B',converter,capture,'--nonce',nonce,'--output',output),'decode accepted')
  assert.call(File.read(File.join(output,'skills.json')).include?('"mp_cost":18'),'post apply data captured')
  assert.call(!File.exist?(File.join(output,'fs_boot_final_authority.json')),'cannot self authorize')
  assert.call(!system(env,RbConfig.ruby,script,chdir:root,out:File::NULL,err:File::NULL),'capture overwrite denied')
  File.write(File.join(capture,'COMPLETE.tsv'),"fake\n")
  assert.call(!system('python3','-I','-B',converter,capture,'--nonce',nonce,'--output',File.join(base,'bad'),out:File::NULL,err:File::NULL),'fake completion rejected')
  puts "FS_VX_CAPTURE_KIT_PASS; Checks=#{checks}; Synthetic=True; OriginalVXRuntime=False"
end
