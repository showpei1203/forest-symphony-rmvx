# 2026-11-28｜OWNER PRODUCTION SIZE AND MASS-PRODUCTION UPDATE (active)
Owner: use PixelLab's supported native map dimensions rather than forcing current large sizes. Match actual SAMPLE MAPS style; transparent layering must pass. Ground first, then one complete all-non-ground RGBA PAR, matching native size and origin; no reverse extraction or patchwork. First complete smaller map then a distinct repeat, with actual reference and native Godot/ART evidence. D34 fixed-size failure is historical, not a prerequisite for new maps; no overwrite of D33. T-B accelerate repeatable original three-stage families, shared map/battle sprites, static identity then Idle/Walk/Attack, optional eight-direction stills, same pipeline across two independent families. T-A remains stopped. Source Skills: https://github.com/showpei1203/tankentai-sbs-godot/blob/feat/ai-agent-skill-library-20261123/ai_agent_skills/.agents/skills/fs-map-ground-par/SKILL.md and https://github.com/showpei1203/tankentai-sbs-godot/blob/feat/ai-agent-skill-library-20261123/ai_agent_skills/.agents/skills/fs-monster-evolution/SKILL.md. These are production specifications, not new asset PASS. Existing cost/rights/P0 gates unchanged.

---

# 2026-11-27｜OWNER TASK RESET／現行優先於下列歷史規格

2026-11-27 使用者最新決策：T-A 停止新角色與動作生成（含 Flow／PixelLab），Godot 直接沿用原 FS 素材、共用地圖／戰鬥 Sprite 及原紙娃娃規格；保留所有歷史成果。T-B 改為 PMD 像素風格與骨架／尺度／動作語法參考，製作山海經靈感的原創異獸及自創三階進化鏈，不再按 PMD 物種編號逐隻改色或照抄。T-C 必須先實際讀取 Drive 已完成地圖範本，分析位置失準原因，再以凍結 Ground 和範本建立可視化座標約束，一次生成整張透明全非地表 PAR。舊任務、NEXT、逐號規則及事後局部修補法如有衝突均降為歷史；已核准素材不得重做。成果優先，沿用已提供素材與 Skills，不為微小細節反覆開發驗收工具；同法兩次失敗即改變生成方法。原有授權、成本、私有儲存及真實驗收規則不變。

T-B 生產規格：先完成一個原創家族三階靜態全身對照，固定家族視覺 DNA、視角、原生格尺寸／比例（依現行素材，不一律改成32px）、屬性、生態與骨架；階段須有結構成長，不能只是換色。PMD 僅作風格及姿勢／時間／方向參考，不能直接把現有 PMD atlas 改色宣稱新怪。PixelLab 用於真正原創造型與必要的動作外觀，沿用已有可用流程；靜態合格後做 Idle、Walk、Attack 等既定動作及 Godot 真實展示，再推進下一家族。第一批建議（名稱及編號為暫定新設計 ID，不覆蓋舊 PMD0001/0002）：炎山系 炭角獸→熔甲獸→燼岳獓；水澤系 霧鱗童→寒澤虯→玄淵螭；雷木系 雷芽鳥→木霆鴞→震林鸞。已核准 PMD0001 保留，舊 0002 配色候選歸檔，不再作新線目標。山海經靈感不等於原典所載物種。

T-C 一次生成正確 PAR：先從 Drive 實際下載成品範本及可取得的同源 Ground/PAR；比較道路、橋兩岸、入口、建物底座、格線、透視、物件相對尺度、留白及可通行區，區分模型構圖漂移、畫布變換、透視或腳點誤判，不以尺寸當唯一根因。針對新地圖先凍結完整 Ground，以同世界原點及像素座標製作整張可視化佈局輸入（橋面中心線及兩岸落點、門口與道路、建築占地、禁入/留空區），結合範本風格與完整物件清單；使用可接受空間條件的既有工具／PixelLab 能力進行一次整幅透明 RGBA 生成，PAR 包含所有非 Ground 物件，不按角色遮蔽篩選。不得事後移橋、剪島、拼件、Master逆切或反覆全圖平移來冒充正確生成。原圖保留；僅允許必要的統一畫布轉換作候選預覽，不能假稱原生或正確對位。生成後直接與不變 Ground 疊合，檢視真實道路／橋接點及整體美術，達標才進 Godot 4.7.2 單次實際場景終檢；失敗修正上游視覺條件或換能控制空間的生成方式，不再重複同類自由提示或添加 gate。目標是一次命中，不保證模型每次成功。先完成一張可用地圖，再按六地形十二圖既定次序量產。

---

# Forest Symphony | Unified Control and Verified Delivery | 2026-11-24

STATUS: This protocol is present on main; workline acceptance and runtime activation remain separately gated. Historical governance pilot branch: feat/fs-unified-orchestration-20261124.
This is NOT an automatic agent, a scheduled worker, or an art/gameplay completion claim.

## Effective authority and conflict resolution

Precedence: (1) current explicit user instructions (within safety and account permissions), (2) account-wide Google Drive 00_GLOBAL_HARD_RULES / FS cloud-only P0, (3) the most recent active task-specific CURRENT_HANDOFF and verified source/Drive evidence, (4) the approved Godot 4.7.2 three-line Roadmap and control-tower protocol, (5) project-specific skills/asset precheck, (6) legacy VX and Master-first methods for historical/source compatibility. Do not erase old successful tests or SHA records.

New development engine: GODOT 4.7.2. VX/RGSS2 survives only as source material and scoped event-behavior compatibility; never restart new FS gameplay development in VX. Historical VX collision/203 tests remain historical, NOT proof of Godot gameplay.

T-C CURRENT USER DECISION: FIRST make a complete TRUE GROUND (terrain, floor, grass, flowers); SECOND separately generate one complete TRUE TRANSPARENT PAR containing ALL NON-GROUND buildings, trees, rocks, props and so on, with no occlusion membership filtering. Preserve shared canvas, pixel geometry, style and explicit compositing/QA. This is the new T-C factory contract, overriding the 2026-11-07 new-village Master-first pipeline *for new T-C generation*. Keep Master-first documents as historical or specifically scoped previous experiments. If the second output is an opaque full scene, it is NOT a PAR and must fail. Later runtime occlusion may be a derived subset, never a reason to omit objects from the delivered authoring PAR.

T-A: approved ACTOR01 identity, 45-degree battle view, real poseable paper-doll source with separately authored hidden underpaint; preserve Body/Weapon/FX, 12 frames where explicitly required by the current paperdoll contract, 64x64 where current task requires; source-pinned Flow/recovered clips retain their approved actual frame count and timing. R23 seven visible-only source masks have technical proof but are NOT independently poseable underlying anatomy: never claim missing belly/arms undercoat are solved.

T-B: true source-locked monster identity and three-stage evolution, approved provider jobs only, cost ledger, no blind paid retry. R19 native test proves art-only sprite clips, not user art approval or FSBattle/ATB/ACT integration.

## Unified start-of-task steps (not optional for FS work)

1. Classify exactly one owner lane T-C / T-A / T-B / GODOT / CONTROL; if ambiguous and still useful, choose CONTROL for triage, DO NOT execute mutations based on a guess.
2. Read current global Drive P0, this protocol, FS routing SKILL.md, project precheck for applicable work, and PC tool routing protocol if a Windows operation is actually needed. Explicitly record which Skill text was truly read, not merely installed or present.
3. Fetch the chosen lane's actual branch HEAD, CURRENT_HANDOFF, its latest addendum/source + Failure Log, current relevant Roadmap, and linked private Google Drive evidence as permitted. Resolve contradictory lines by explicit dated/current verified authority, preserving older text as history. Handoff is progress/evidence, not an independent policy author; any claimed policy change needs explicit user decision or canonical authority.
4. Select least-privilege route: direct GitHub/Drive/Linear connectors -> authorized MCP/API -> allowlisted PC Bridge ONLY if Windows execution is essential and P0 permits -> verified restricted Orca agent where available -> Desktop Remote for authorized web/GUI or inefficient/unreliable Runner work, per current owner standing authorization. Explicit restrictions and high-risk confirmations remain. No Codex and no arbitrary shell via PC Bridge. The tool-choice table grants no new access rights.
5. Deliver ONE macro unit (M1 full candidate -> M2 actual Godot native -> M3 blocking fixes -> M4 repeat second distinct case). Avoid revisiting already paid provider jobs or modifying approved sources.
6. Produce source SHA/rights, actual tool and model calls, live native runner marker, owner visual judgment, complete gameplay integration result, separate STATUS gates, Failure Log, and cloud WRITE -> READBACK evidence.
7. Update only the lane-owned files/branch, with Handoff. CONTROL alone owns central tower status. Every new chat must explicitly fetch fresh remote sources; a checked-in Skill does NOT mean ChatGPT, Orca or Cherry automatically loads or invokes it.

## Required evidence levels (no false promotions)

- INSTALLED: software/Skill file exists; does NOT prove invoked.
- DISCOVERED: relevant Skill path found in the actual active host.
- LOADED: complete Skill instructions were actually read in this task, with ref/version.
- INVOKED: a matching tool/API/CLI really called; identifiable run/job and relevant output.
- TECH_PASS: measured file/schema/regression checks for the actual revision and actual input.
- GODOT_NATIVE_PASS: an actual Godot 4.7.2 run, pinned source, explicit run/marker and output.
- ART_PASS: visual pass by the user or authorized art reviewer for actual assets at 1x.
- GAMEPLAY_PASS: in the actual FS gameplay scene, relevant ATB/ACT/events, not isolated sprite gallery.
- DELIVERED: persisted to correct GitHub branch/private Drive, re-read and verified sizes/SHA as appropriate.
- REPEATABLE: same workflow succeeds for independent second sample with preserved identity and comparable quality.

No promotion from lower levels. ART_HOLD and NOT_RUN do not disappear when the Python/Godot smoke test succeeds.

## Minimum evidence and reporting

Use tools/agent_orchestration/proof_template.json per finished unit; store private paths only as owner-only Drive URLs or sanitized IDs. tools/agent_orchestration/validate_evidence.py is a STRUCTURAL checker: it checks the logical proof gate, not actual remote run validity. Truly validate URLs/commit/permissions/bytes using the connected provider and record independently. Never publish private art/keys/PC user information in public GitHub.

Required Handoff fields: LANE, PHASE, SOURCE (ID/sha/rights), DELTA and before/after, SKILLS_LOADED (exact path/ref and note any unavailable), TOOLS_CALLED, PROVIDER_JOB/cost and paid retry prevention, TECH_GATES, GODOT_NATIVE evidence, USER_ART verdict, GAMEPLAY verdict, P0 temporary scope/approval/cleanup, cloud WRITE/READBACK, FAILURES, NEXT_MACRO_UNIT. No result means NOT_RUN, not optimistic PASS.

## Live state pointers (read current branch, don't reuse stale excerpts)

- T-C: feat/fs-pixellab-tc-map-20261121 / godot_port/docs/handoff/PIXELLAB_TC_CURRENT_HANDOFF.md / SHO-39. Latest checked D11 volcano Ground candidate, CompletePAR failed alpha; D11 native NOT_RUN, 0/12 ART sealed.
- T-A: feat/fs-pixellab-ta-actor-20261121 / godot_port/docs/handoff/PIXELLAB_TA_CURRENT_HANDOFF.md / SHO-38. Latest checked R23 seven visible-layer technique native PASS, real poseable paperdoll and full gameplay ART_HOLD/NOT_RUN.
- T-B: feat/fs-pixellab-tb-monster-20261121 / godot_port/docs/handoff/PIXELLAB_TB_CURRENT_HANDOFF.md / SHO-37. Latest checked R19 true SKILL 3-stage original art native PASS, owner visual AWAIT, full gameplay NOT_RUN.
- GODOT: feature/fs-godot-phase1; inspect current branch Handoff and latest code before any edit.
- CONTROL: research/fs-pixellab-deep-study-20261121 / godot_port/docs/research/launch/FS_CONTROL_TOWER_PROTOCOL.md. Its last published central status may lag the three live lanes, and is never live monitoring.

## P0 and old PC clone issue

Permanent new outputs ONLY Drive/GitHub; locally installed software and unavoidable runtime environment are exceptional. Creating test/source clones in the OWNER's Windows PC requires scoped user authorization under global P0, cloud verified results and cleanup evidence; do not assume previous successful runs authorize future scratch folders. Historical fs-sprite-gen-adapter-4fb64b2 clone remains CLEANUP_UNVERIFIED and is not re-run or deleted without a separately authorized audit.

## Startup promise / limitation

To start a new FS chat with this mechanism, configure ChatGPT Project instructions to point to this protocol and tools/agent_orchestration/routing_manifest.json. ChatGPT cannot guarantee a future instance will have every connector available; if remote fetch fails, disclose which gate is BLOCKED. No tool activation is inferred from a file being present. A brand-new chat not in this Project may need the short repository link at least once.
