# Story 004: 마을 한 구역·주민·빈집 휴식 장면

> **Epic**: Undertopia
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: (set by /dev-story when implementation begins)

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 2`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 2, Art & audio direction), scoped to this story:*

- [ ] 마을 한 구역이 도트 그래픽으로 표시되고 주인공이 돌아다닐 수 있다.
- [ ] 네 동물 주민(곰·고양이·토끼 자매·강아지)이 마을에 서 있고, 어긋난 점이 행동으로 읽힌다(몸이 아니라 행동).
- [ ] 주민이 보스전 전에는 상호작용으로 짧은 텍스트 대사를 보여 준다.
- [ ] 빈집에서 쉬는 짧은 장면이 있다: 식탁에 좋아하는 음식이 놓이고, 침대가 몸에 맞게 바뀐다.
- [ ] 휴식 장면은 보스전 사이에 들어갈 수 있다(각 보스 구함 뒤).
- [ ] 색감은 따뜻하고, 실루엣은 둥글고 읽기 쉽다.
- [ ] 실행해서 마을과 휴식 장면을 확인하고, 화면마다 스크린샷을 `production/qa/evidence/`에 남기고 승인 기록(`[slug]-evidence.md`)을 쓴다.

---

## Implementation Notes

- 주민의 보스전 연결은 각 보스 스토리가 맡는다. 여기서는 마을 배치와 상호작용 진입점만 만든다.
- 해상도와 UI 크기를 고정하지 않는다(모바일·웹 이식 가능성).

---

## Out of Scope

- 빈집 따라다니기, 가구 수집(브리프 범위 밖)
- 보스전 자체(Story 002, 003, 005~007)

---

## Files

- `src/village/`
- `production/qa/evidence/village-evidence.md`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**:
- Visual/Feel: 보존된 스크린샷 + 승인 기록(`production/qa/evidence/village-evidence.md`)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/undertopia/story-001-combat-rescue-frame.md`
- Unlocks: None
