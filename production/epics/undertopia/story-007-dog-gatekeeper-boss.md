# Story 007: 강아지 문지기 보스

> **Epic**: Undertopia
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: (set by /dev-story when implementation begins)

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 6`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 6, 소원 구절 "집"), scoped to this story:*

- [ ] 강아지 문지기는 나가려는 사람을 꼬리 치며 집으로 데려오는 모습으로 등장한다.
- [ ] 보스전이 시작되면 강아지가 주인공의 물건을 물고 달아나고, 문밖으로 나갈 때마다 안으로 끌고 온다(넘침 규칙은 이 하나뿐이다).
- [ ] 달아나는 강아지를 쫓아 물건을 되찾을 수 있다.
- [ ] 과잉을 걷어 내면 강아지가 원래 모습으로 돌아온다.
- [ ] 구하기 동작: 머리를 쓰다듬고 "다녀올게"라고 말한 뒤, 강아지가 지켜보는 앞에서 문을 나선다.
- [ ] 이 구하기는 이후 빈집과의 작별(Story 003)을 미리 연습하는 장면으로 읽힌다.
- [ ] 소원 구절 "집"이 구함 직후 드러난다.
- [ ] 실행해서 보스전과 구하기 장면을 확인하고 스크린샷을 `production/qa/evidence/`에 남긴다.

---

## Implementation Notes

- Story 001의 틀 위에 구현한다. 강아지 속도, 끌고 오는 힘 등은 외부 데이터로 둔다.

---

## Out of Scope

- 다른 동물 보스(Story 002, 005, 006), 2페이즈(브리프 범위 밖)

---

## Files

- `src/bosses/dog/`
- `tests/integration/boss_dog/dog_rescue_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/integration/boss_dog/dog_rescue_test.gd` 또는 플레이테스트 기록 (`qa.level: minimal`에서는 면제)
- 플레이어에게 보이는 변경이므로 보존된 스크린샷: `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/undertopia/story-001-combat-rescue-frame.md`, `story-002-bear-baker-boss.md`
- Unlocks: `story-003-empty-house-finale.md`의 마지막 기준
