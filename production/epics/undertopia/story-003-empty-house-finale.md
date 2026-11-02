# Story 003: 작은 빈집(최종 보스)과 엔딩

> **Epic**: Undertopia
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: (set by /dev-story when implementation begins)

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 7`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 7, Player goal & fail state), scoped to this story:*

- [ ] 빈집 보스전에는 체력이 없고 주인공을 해치지 않는다.
- [ ] 빈집은 문을 닫고, 계단을 접고, 좋아했던 것들을 쌓아 길을 막는다.
- [ ] 주인공은 쌓인 것들을 치우며 출구로 나아간다.
- [ ] 길이 완전히 막히면 시작 방으로 돌아간다(실패 조건).
- [ ] 구한 네 주민(곰·고양이·토끼 자매·강아지)이 길을 열어 준다.
- [ ] 출구에서 돌아서서 작별 인사를 하는 것이 구하기 동작이다.
- [ ] 소원 문장 "모두 배부르고, 아무도 아프지 않고, 서로 헤어지지 않는, 집이 있었으면 좋겠어"가 완성되어 연출된다.
- [ ] 엔딩: 주인공이 떠나고, 작은 집의 문 앞에 지상에서 온 편지가 놓인다. 엔딩은 하나뿐이다.
- [ ] 실행해서 보스전과 엔딩을 확인하고 스크린샷을 `production/qa/evidence/`에 남긴다.

---

## Implementation Notes

- 빌드 순서상 이 스토리를 일찍 만든다(가장 미검증). "네 주민이 길을 연다"는 기준은 Story 005~007이 끝나기 전에는 임시 대역으로 두고, 그 스토리들이 끝난 뒤 이 기준만 다시 확인한다.
- 이 기준이 확인되기 전에는 이 스토리를 Done으로 닫지 않는다.

---

## Out of Scope

- 빈집이 따라다니는 동료 시스템(브리프 범위 밖)
- 엔딩 분기, 음성 대사

---

## Files

- `src/bosses/empty_house/`
- `src/ending/`
- `tests/integration/boss_house/house_ending_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/integration/boss_house/house_ending_test.gd` 또는 플레이테스트 기록 (`qa.level: minimal`에서는 면제)
- 플레이어에게 보이는 변경이므로 보존된 스크린샷: `production/qa/evidence/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/undertopia/story-001-combat-rescue-frame.md`. 마지막 기준은 `story-002-bear-baker-boss.md`, `story-005-cat-tailor-boss.md`, `story-006-rabbit-sisters-boss.md`, `story-007-dog-gatekeeper-boss.md`가 끝나야 확인 가능.
- Unlocks: None
