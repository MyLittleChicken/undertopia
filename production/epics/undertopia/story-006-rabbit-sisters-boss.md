# Story 006: 토끼 자매 보스

> **Epic**: Undertopia
> **Status**: Superseded
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-03

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 5`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 5, 소원 구절 "헤어지지 않는"), scoped to this story:*

- [ ] 토끼 자매는 리본으로 묶인 두 캐릭터로 표현된다(한 몸이 아니다). 늘 티격태격한다.
- [ ] 보스전이 시작되면 리본이 건물을 묶어 전장이 점점 좁아진다(넘침 규칙은 이 하나뿐이다).
- [ ] 리본을 끊어 공간을 되찾을 수 있다. 많이 끊을수록 남은 리본이 더 세게 당긴다.
- [ ] 모든 과잉을 걷어 내면 자매가 원래 모습으로 돌아온다.
- [ ] 구하기 동작: 매듭을 자르지 않고 서로 멀어질 수 있을 만큼 느슨하게 푼다.
- [ ] 구한 뒤 자매는 잠깐 등을 돌리고 있을 수 있다.
- [ ] 소원 구절 "헤어지지 않는"이 구함 직후 드러난다.
- [ ] 실행해서 보스전과 구하기 장면을 확인하고 스크린샷을 `production/qa/evidence/`에 남긴다.

---

## Implementation Notes

- Story 001의 틀 위에 구현한다. 전장 크기 변화는 이후 모바일·웹 이식을 고려해 화면 크기에 고정하지 않는다. 당기는 세기와 좁아지는 속도는 외부 데이터로 둔다.

---

## Out of Scope

- 다른 동물 보스(Story 002, 005, 007), 2페이즈(브리프 범위 밖)

---

## Files

- `src/bosses/rabbits/`
- `tests/integration/boss_rabbits/rabbit_rescue_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/integration/boss_rabbits/rabbit_rescue_test.gd` 또는 플레이테스트 기록 (`qa.level: minimal`에서는 면제)
- 플레이어에게 보이는 변경이므로 보존된 스크린샷: `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/undertopia/story-001-combat-rescue-frame.md`, `story-002-bear-baker-boss.md`
- Unlocks: `story-003-empty-house-finale.md`의 마지막 기준
