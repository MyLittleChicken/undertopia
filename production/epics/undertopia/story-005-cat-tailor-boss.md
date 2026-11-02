# Story 005: 고양이 재봉사 보스

> **Epic**: Undertopia
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: (set by /dev-story when implementation begins)

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 4`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 4, 소원 구절 "아프지 않고"), scoped to this story:*

- [ ] 고양이 재봉사 보스전이 시작되면 솜과 붕대가 날아와 주인공을 감싼다(넘침 규칙은 이 하나뿐이다).
- [ ] 많이 감길수록 주인공이 움직이기 어렵고, 회피나 공격으로 풀어낼 수 있다.
- [ ] 공격으로 솜과 붕대의 과잉을 걷어 내면 고양이가 원래 모습으로 돌아온다.
- [ ] 구하기 동작: 주인공이 자기 상처를 보여 주고 "이 정도는 괜찮아"라고 말한다.
- [ ] 구한 뒤 고양이는 작은 상처를 모두 꿰매지 않고 지켜볼 수 있다.
- [ ] 소원 구절 "아프지 않고"가 구함 직후 드러난다.
- [ ] 실행해서 보스전과 구하기 장면을 확인하고 스크린샷을 `production/qa/evidence/`에 남긴다.

---

## Implementation Notes

- Story 001의 틀과 Story 002의 보스 구성 방식을 따른다. 솜/붕대 속도와 감김 한계는 외부 데이터로 둔다.

---

## Out of Scope

- 다른 동물 보스(Story 002, 006, 007), 2페이즈나 두 번째 넘침 규칙(브리프 범위 밖)

---

## Files

- `src/bosses/cat/`
- `tests/integration/boss_cat/cat_rescue_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/integration/boss_cat/cat_rescue_test.gd` 또는 플레이테스트 기록 (`qa.level: minimal`에서는 면제)
- 플레이어에게 보이는 변경이므로 보존된 스크린샷: `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/undertopia/story-001-combat-rescue-frame.md`, `story-002-bear-baker-boss.md`
- Unlocks: `story-003-empty-house-finale.md`의 마지막 기준
