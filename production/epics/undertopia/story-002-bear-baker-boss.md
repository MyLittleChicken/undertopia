# Story 002: 곰 제빵사 보스

> **Epic**: Undertopia
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: (set by /dev-story when implementation begins)

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 3`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 3, 소원 구절 "배부르고"), scoped to this story:*

- [ ] 곰 제빵사 보스전이 시작되면 오븐이 멈추지 않고 빵을 만들어 낸다(넘침 규칙은 이 하나뿐이다).
- [ ] 걸어 다니는 빵에 닿으면 주인공이 안겨 점점 무거워지고 느려진다. 회피로 벗어날 수 있다.
- [ ] 공격으로 빵과 오븐의 과잉을 걷어 낼 수 있고, 모두 걷히면 곰이 원래 모습으로 돌아온다.
- [ ] 구하기 동작: 곰이 내미는 빵 한 조각을 건네 곰이 처음으로 앉아서 먹게 한다.
- [ ] 구한 뒤 곰은 손님이 배부르다고 하면 오븐을 끄고 자기 접시에도 빵을 올린다.
- [ ] 곰의 모습은 몸을 떼어 빵을 굽거나 입 달린 빵이 등장하지 않는다(그로테스크 표현 제외).
- [ ] 소원 구절 "배부르고"가 구함 직후 드러난다.
- [ ] 실행해서 보스전과 구하기 장면을 확인하고 스크린샷을 `production/qa/evidence/`에 남긴다.

---

## Implementation Notes

- Story 001의 구하기 틀 위에 곰의 규칙만 얹는다. 빵 속도, 오븐 간격 등 수치는 외부 데이터로 둔다.

---

## Out of Scope

- Story 005~007: 다른 동물 보스
- Story 003: 소원 문장 전체 연출은 빈집전과 엔딩에서

---

## Files

- `src/bosses/bear/`
- `tests/integration/boss_bear/bear_rescue_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/integration/boss_bear/bear_rescue_test.gd` 또는 플레이테스트 기록 (`qa.level: minimal`에서는 면제)
- 플레이어에게 보이는 변경이므로 보존된 스크린샷: `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/undertopia/story-001-combat-rescue-frame.md`
- Unlocks: `story-005-cat-tailor-boss.md`, `story-006-rabbit-sisters-boss.md`, `story-007-dog-gatekeeper-boss.md`
