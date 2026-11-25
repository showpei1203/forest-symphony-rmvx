#!/usr/bin/env python3
"""Privately compare exact original Game_Troop methods with raw page metadata.
No original event commands, full VX boot or production approval.
"""
import argparse
import io
import json
from pathlib import Path
import subprocess
import zipfile
from craft_raw_troop_inventory import inventory, digest, MAX_ZIP
from rvdata_to_json import RubyMarshal48

RUBY = r'''
require 'json'
require 'ostruct'
d=JSON.parse(STDIN.read)
Page=Struct.new(:condition,:span,:list)
class Interpreter
  attr_reader :selected
  def running?; false; end
  def setup(list); @selected=list; end
  def clear; @selected=nil; end
end
class OracleTroop
  attr_reader :interpreter,:event_flags
  def initialize(pages); @troop=Struct.new(:pages).new(pages); @interpreter=Interpreter.new; @event_flags={}; @turn_ending=false; end
  def troop; @troop; end
  def turn(n); @turn_count=n; end
end
OracleTroop.class_eval(d.fetch('source'),'exact raw source #21 conditions/setup',153)
$game_temp=Struct.new(:common_event_id).new(0)
counts=Hash.new(0)
condition_checks=0
flag_checks=0
repeats=0
mismatches=0
d.fetch('troops').each do |rows|
  pages=rows.map{|p|Page.new(OpenStruct.new(p['condition']),p['span'],[p['index'],p['nonempty']])}
  $game_troop=OracleTroop.new(pages)
  4.times do |n|
    $game_troop.turn(n)
    rows.each_with_index do |row,i|
      c=row['condition']
      expected=c['turn_valid'] && c['turn_a']==n && c['turn_b']==0 && !$game_troop.event_flags[pages[i]]
      actual=$game_troop.conditions_met?(pages[i])
      mismatches+=1 if actual!=expected
      condition_checks+=1
    end
    (pages.size+1).times do
      $game_troop.interpreter.clear
      $game_troop.setup_battle_event
      selection=$game_troop.interpreter.selected
      break if selection.nil?
      p=pages[selection[0]]
      counts[n.to_s]+=1 if selection[1]
      flag_checks+=1
      repeats+=1 unless $game_troop.event_flags[p] && !$game_troop.conditions_met?(p)
    end
  end
end
raise 'source selection mismatch' unless mismatches==0 && repeats==0
puts JSON.generate({condition_checks:condition_checks,flag_checks:flag_checks,nonempty_selection_by_turn:counts,condition_mismatches:mismatches,repeat_failures:repeats,original_runtime_executed:false,scope:'exact #21 methods on actual raw page metadata; no event commands executed'})
'''


def run(path, pin):
    report = inventory(path, pin)
    path = Path(path)
    if path.stat().st_size > MAX_ZIP:
        raise ValueError('archive size changed')
    raw = path.read_bytes()
    if len(raw) > MAX_ZIP or digest(raw) != pin:
        raise ValueError('archive bytes changed')
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        src = z.read('rgss2/022.rb')
        # Exact independently audited source file, not arbitrary supplied code.
        expected = 'd576e3f55071ff875e74a8e0db30cb6dbbcd0e03'
        import hashlib
        blob = hashlib.sha1(b'blob ' + str(len(src)).encode() + b'\0' + src).hexdigest()
        if blob != expected:
            raise ValueError('original Game_Troop blob mismatch')
        lines = src.decode('utf-8').splitlines()
        methods = '\n'.join(lines[152:186] + lines[189:206])
        rows = RubyMarshal48(z.read('Data/Troops.rvdata')).parse()
        troops = []
        for row in rows:
            if row is None:
                continue
            pages = []
            for i, page in enumerate(row['pages']):
                c = {k: v for k, v in page['condition'].items() if k != '__ruby_class__'}
                if any(c[k] for k in ('enemy_valid', 'actor_valid', 'switch_valid', 'turn_ending')) or page['span'] != 0 or c['turn_b'] != 0:
                    raise ValueError('page is outside scoped raw turn oracle')
                pages.append({'index': i, 'condition': c, 'span': page['span'],
                              'nonempty': any(x['code'] != 0 for x in page['list'])})
            troops.append(pages)
    # Only the pinned original two methods and private page metadata are passed.
    # No event parameter, event script, full original Ruby or filesystem output.
    result = subprocess.run(['ruby', '-e', RUBY], input=json.dumps({'source': methods, 'troops': troops}),
                            text=True, capture_output=True, timeout=15, check=True)
    outcome = json.loads(result.stdout)
    if outcome['condition_checks'] != report['counts']['pages'] * 4:
        raise ValueError('oracle check count mismatch')
    if sum(outcome['nonempty_selection_by_turn'].values()) != report['counts']['conditioned_nonempty_pages']:
        raise ValueError('oracle source selection count mismatch')
    return outcome


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('archive')
    p.add_argument('--sha256', required=True)
    a = p.parse_args()
    print(json.dumps(run(a.archive, a.sha256), sort_keys=True, indent=2))
