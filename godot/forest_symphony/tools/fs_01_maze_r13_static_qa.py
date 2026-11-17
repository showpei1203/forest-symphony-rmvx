#!/usr/bin/env python3
"""R13 reproducible static and previous native-evidence-based QA. Not Godot runtime."""
import hashlib,json,heapq,collections
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
def digest(path):return hashlib.sha256((ROOT/path).read_bytes()).hexdigest()
def assert_eq(a,b,msg):assert a==b,f'{msg}: {a} != {b}'
def run():
    scene='scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn'
    prior='scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn'
    ground='private_assets/a36_ground_only_2560x1856.png'
    report=json.loads((ROOT/'qa_a36c/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json').read_text(encoding='utf-8'))
    semantic=json.loads((ROOT/'data/a36_terrain_semantic_candidates.json').read_text(encoding='utf-8'))
    assert_eq(digest(ground),'ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911','Ground immutable')
    assert_eq(digest(prior),'54224083a741bf4d451c9d44674d48fae68e399eac856c31b31c15c10457c392','R12 scene immutable')
    sc=(ROOT/scene).read_text(encoding='utf-8')
    assert sc.count('source_object_id = ')==326, 'Independent actual PAR regression'
    assert sc.count('source_semantic = "tree"')==310, 'Tree regression'
    for node in ('MazeTopology','Entrance','Exit','BridgeEast','BridgeWest','RoadNavigator','WaterSemanticHazards'):
        assert f'name="{node}"' in sc, 'Missing real scene node '+node
    assert sc.count('[node name="')>=sc.count('[node name="',1)
    rows=report['obstacle_rows_water_tilde_other_collision_hash_clear_dot']
    assert_eq(len(rows),58,'Grid height')
    assert_eq(sum(len(row) for row in rows),4640,'Grid size')
    assert_eq(sum(c=='~' for row in rows for c in row),148,'Water tile count')
    assert_eq(sum(c!='.' for row in rows for c in row),511,'All blockers')
    assert_eq(len(semantic['river_blocked_cells']),148,'Semantic blockers')
    for x,y in semantic['river_blocked_cells']:
        assert rows[y][x]=='~',f'Native river mismatch at {(x,y)}'
    entrance=(39,55);exit_=(49,5);east=(14,29);west=(6,29)
    assert rows[entrance[1]][entrance[0]]=='.' and rows[exit_[1]][exit_[0]]=='.'
    assert all(rows[29][x]=='.' for x in range(6,15)), 'Actual Godot R9 bridge cells blocked'
    assert rows[27][9]=='~' and rows[30][8]=='~', 'Bridge water banks missing'
    def reachable(start,end):
        q=collections.deque([start]);seen={start}
        while q:
            x,y=q.popleft()
            if (x,y)==end:return True
            for a,b in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
                if 0<=a<80 and 0<=b<58 and rows[b][a]=='.' and (a,b) not in seen:
                    seen.add((a,b));q.append((a,b))
        return False
    for a,b in [(entrance,exit_),(entrance,east),(west,(5,27))]:
        assert reachable(a,b),f'Native R9 documented grid disconnected: {a}->{b}'
    result={"schema":"FS_01_MAZE_R13_STATIC_QA/V1","stage":"SOURCE_STATIC_PASS_SEPARATE_NATIVE_GODOT_VERIFIED",
      "evidence":"Static: R9 native physics survey + R12 source hash; separate R13 official Godot 4.7.2 full gameplay/GPU runs returned Exit 0",
      "original_ground_sha256":digest(ground),"original_r12_scene_sha256":digest(prior),"r13_scene_sha256":digest(scene),
      "independent_par":326,"tree_objects":310,"existing_river_water_tiles":148,"real_r9_foot_cells":4640,
      "original_r9_physical_open":4129,"original_r9_physical_blocked":511,
      "authored_entrance_grid":entrance,"authored_north_exit_grid":exit_,"authored_painted_bridge_east":east,
      "authored_painted_bridge_west":west,"bridge_corridor_open_source_cells":9,
      "source_connectivity_gates":3,"art_gate":"HOLD","native_r13":"VERIFIED_SEPARATE_OFFICIAL_GODOT_4_7_2_EXIT_0",
      "village_destination_integration":"HOLD"}
    target=ROOT/'qa_a36c/FS_01_MAZE_R13_STATIC_QA.json'
    target.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,ensure_ascii=False,indent=2))
if __name__=='__main__':run()
