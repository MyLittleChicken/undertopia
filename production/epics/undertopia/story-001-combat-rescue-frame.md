# Story 001: 전투 틀과 구하기 흐름

> **Epic**: Undertopia
> **Status**: Superseded
> **Layer**: Core
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-03

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 1`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). 4.7은 학습 범위를 넘으므로 API 사용 전 `docs/engine-reference/godot/` 확인.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop, Player goal & fail state), scoped to this story:*

- [ ] 주인공이 키보드/마우스로 이동·공격·회피·상호작용을 할 수 있다. 모든 조작은 InputMap 액션 이름으로 받는다.
- [ ] 보스는 "넘침" 상태에서 시작하고, 공격이 넘친 부분(과잉)을 걷어 내 수치를 줄인다.
- [ ] 과잉이 모두 걷히면 보스가 "원래 주민" 상태로 전환되고 구하기 동작이 활성화된다.
- [ ] 구하기 동작이 보스별로 다른 입력/조건을 받을 수 있는 구조다(공통 틀 + 보스별 규칙).
- [ ] 구하기에 성공하면 보스전이 끝나고 "구함" 상태가 기록된다.
- [ ] 동물 보스전에서 주인공 체력이 0이 되면 그 보스전만 처음부터 다시 시작한다.
- [ ] 회피 중 무적 시간 등 전투 수치는 코드에 하드코딩하지 않고 외부 데이터(리소스)로 둔다.
- [ ] 실행해서 플레이어가 보이는 화면에서 위 흐름을 확인하고 스크린샷을 `production/qa/evidence/`에 남긴다.

---

## Implementation Notes

- 구하기 흐름은 상태 기계(넘침 → 원래 주민 → 구함)로 두고, 보스별 규칙은 별도 리소스/스크립트로 주입한다.
- 이 틀이 이후 모든 보스 스토리의 기반이다. 곰(002)으로 재미를 먼저 검증한다.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002, 005, 006, 007: 각 동물 보스의 패턴과 구하기 동작
- Story 003: 빈집 보스(체력 없는 싸움)
- Story 004: 마을과 NPC

---

## Files

- `src/combat/boss.gd`
- `src/combat/boss_data.gd`
- `src/combat/combat_demo.tscn`
- `src/combat/combat_encounter.gd`
- `src/combat/default_boss.tres`
- `src/combat/default_hold_rule.tres`
- `src/combat/default_player.tres`
- `src/combat/hold_interact_rule.gd`
- `src/combat/input_setup.gd`
- `src/combat/player_data.gd`
- `src/combat/rescue_rule.gd`
- `src/player/player.gd`
- `tests/playtest/combat/rescue_flow_playthrough.gd`
- `tests/playtest/combat/rescue_flow_playthrough.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived** (advisory), but a retained screenshot of the running game is not.*

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/combat/rescue_flow_test.gd` (권장, `qa.level: minimal`에서는 면제)
- 플레이어에게 보이는 변경이므로 보존된 스크린샷: `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/undertopia/story-002-bear-baker-boss.md`, `story-003-empty-house-finale.md`, `story-004-village-and-rest-scene.md`, `story-005-cat-tailor-boss.md`, `story-006-rabbit-sisters-boss.md`, `story-007-dog-gatekeeper-boss.md`

---

## Completion Notes
**Completed**: 2026-11-02
**Criteria**: closed on 2026-11-02 with the verdict NOT ASSESSED, on the user's explicit choice to accept the then-unverified criteria. Later the same day the unverified ones were covered by a scripted playthrough (below).
**Semi-test passed** (2026-11-02): AC-1 (move, attack, dodge, interact), AC-2 (strip overflow), AC-3 (overflow 0 → original resident), AC-5 (rescue ends the fight, recorded), AC-6 (HP 0 restarts only that fight). This is a scripted playthrough that presses the real InputMap actions frame by frame and checks observable state: `tests/playtest/combat/rescue_flow_playthrough.tscn`, result `SEMI-TEST RESULT: PASS (23 checks, 0 failed)`, log and screenshots in `production/qa/evidence/story-001-combat-rescue-frame/` (`playthrough-result.txt`, `02`–`08-*.png`, all opened and compared). It was also watched failing: with the boss reset removed from `_restart`, exactly the check "AC-6 boss reset to OVERFLOW" failed (exit 1); the line was restored and the source matches the evidence stamp.
**Read, not run**: AC-4 (`RescueRule` injected per boss), AC-7 (combat numbers live in `@export` Resource data).
**NOT verified**: how it feels. A human has not played it: input responsiveness, dodge timing and attack reach are unjudged. The semi-test cannot tell. Play it once before building bosses on it: `godot --path . --windowed --resolution 1280x720 res://src/combat/combat_demo.tscn`.
**Deviations**: ADVISORY — HUD layout numbers are literals in `combat_encounter.gd`; engine-check STYLE findings not applied (see below). Notably `RescueRule.progress` is mutable state on a shared Resource — call `rescue_rule.duplicate()` in `CombatEncounter._ready()` before stories 002 and 005-007.
**Open question**: where the rescued-residents record lives across scenes (`CombatEncounter.rescued_ids` is encounter-local).
**Test Evidence**: no unit test (waived at qa.level minimal); semi-test `tests/playtest/combat/rescue_flow_playthrough.gd` passed; retained screenshots `01`–`08` in `production/qa/evidence/story-001-combat-rescue-frame/`
**Reviewed by**: self, no independent review
