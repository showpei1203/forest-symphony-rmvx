#!/usr/bin/env python3
"""Generate isolated R13 Godot scene from the immutable R12 private scene, no pixel surgery."""
from pathlib import Path
import hashlib

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn'
TARGET=ROOT/'scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn'
R12_SHA='54224083a741bf4d451c9d44674d48fae68e399eac856c31b31c15c10457c392'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def once(s,old,new):
    if s.count(old)!=1:raise AssertionError(f'Expected one unique source token: {old[:90]} count={s.count(old)}')
    return s.replace(old,new,1)
def main():
    assert sha(SOURCE)==R12_SHA,'R12 immutable scene source changed'
    s=SOURCE.read_text(encoding='utf-8')
    s=once(s,'[gd_scene load_steps=6 format=3]','[gd_scene load_steps=8 format=3]')
    s=once(s,'[sub_resource type="RectangleShape2D" id="actor_foot"]',
        '[ext_resource type="Script" path="res://scripts/fs_01_maze_r13_topology.gd" id="6_topology"]\n'
        '[ext_resource type="Script" path="res://scripts/fs_01_maze_r13_walkable_player.gd" id="7_player"]\n'
        '[sub_resource type="RectangleShape2D" id="actor_foot"]')
    s=once(s,'[node name="FS_01_MAZE_R12_LiveRoadNavigation" type="Node2D"]',
        '[node name="FS_01_MAZE_R13_PlayableTopology" type="Node2D"]')
    s=once(s,'position = Vector2(1340, 1050)\nscript = ExtResource("3_player")',
        'position = Vector2(1264, 1776)\nscript = ExtResource("7_player")')
    s+='''\n[node name="MazeTopology" type="Node2D" parent="."]
script = ExtResource("6_topology")
[node name="Entrance" type="Marker2D" parent="MazeTopology"]
position = Vector2(1264, 1776)
[node name="Exit" type="Marker2D" parent="MazeTopology"]
position = Vector2(1584, 176)
[node name="BridgeWest" type="Marker2D" parent="MazeTopology"]
position = Vector2(208, 944)
[node name="BridgeEast" type="Marker2D" parent="MazeTopology"]
position = Vector2(464, 944)
'''
    TARGET.write_text(s,encoding='utf-8')
    print('R13 private full scene rebuilt',len(s),'bytes',sha(TARGET))
if __name__=='__main__':main()
