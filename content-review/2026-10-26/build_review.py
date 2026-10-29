import collections, copy, hashlib, html, json, pathlib, re

ROOT = pathlib.Path(__file__).resolve().parent
if (ROOT / 'moon_messages.youth.json').exists():
    raise SystemExit('청소년 개정본이 있습니다. 현재 검토 화면을 갱신하려면 apply_youth_revision.py를 사용하세요.')
SOURCE = ROOT.parents[1] / 'app' / 'src' / 'data' / 'moon_messages.json'
NAMES = SOURCE.with_name('phase-names.json')
raw = SOURCE.read_bytes()
source = json.loads(raw.decode('utf-8'))
names = json.loads(NAMES.read_text(encoding='utf-8'))
additions = {}
for part in ('00-09', '10-19', '20-29'):
    additions.update(json.loads((ROOT / f'additions-{part}.json').read_text(encoding='utf-8')))
rows = [r for group in source['messages'] for r in group]
assert len(rows) == len(additions) == 150
assert len({(r['age'], r['distance']) for r in rows}) == 150
duplicates = {k: v for k, v in collections.Counter(r['keyword'] for r in rows).items() if v > 1}
revised_target = '''당신은 변화 앞에서 마음을 차분히 정리하고, 자신에게 필요한 것을 다시 고르는 사람입니다. 감정과 생각이 복잡할수록 무엇을 계속 품고 무엇을 덜어낼지 구분하며 자신의 기준을 찾아갑니다.

새로운 일을 맡으면 해야 할 일과 마음에 걸리는 부분을 나눠 살피는 편입니다. 여러 선택지를 한꺼번에 붙잡기보다 우선순위를 정했을 때 집중하기 쉽습니다. 관계에서도 바로 대답하기보다 자신의 마음을 확인할 시간이 필요할 수 있습니다.

다만 정리한다는 이유로 서운함이나 바람까지 불필요한 것으로 여기지는 마세요. 마음은 반드시 말끔해져야 하는 대상이 아닙니다. 아직 설명하기 어려운 감정도 한 문장으로 남겨두면 자신이 원하는 것을 알아가는 단서가 됩니다.

당신의 정돈은 자신을 줄이는 일이 아니라, 소중한 것을 알아보고 그 자리를 지키는 방식입니다.'''
entries = []
proposed = copy.deepcopy(source)
proposed_lookup = {(r['age'], r['distance']): r for g in proposed['messages'] for r in g}
for row in rows:
    age, distance = row['age'], row['distance']
    key = f'{age:02}-{distance}'
    name, supplement = additions[key]
    assert len(name) > 0 and len(supplement) >= 75, key
    flags = []
    if re.search(r'곧|앞으로|머지않아|가까운 미래', row['message']):
        flags.append('성향 글에 미래 예고가 섞임: 일상의 선택과 습관 설명으로 교체 검토')
    if any(w in row['message'] for w in ('누구보다', '정확', '타고난', '탁월', '독보', '특별한')):
        flags.append('능력·성격의 단정 표현 완화 검토')
    if row['keyword'] in duplicates:
        flags.append('이름이 다른 항목과 중복됨')
    if row['phase'].replace(' ', '') != names[age]['ko'].replace(' ', ''):
        flags.append('메시지의 달 표기와 앱 표시명이 다름: 이름 기준 정리 필요')
    if '예지' in row['keyword'] or '예지' in row['message']:
        flags.append('예지력은 관찰·직감의 상징으로 표현할 것: 실제 예측 능력으로 단정하지 않기')
    if key == '26-2':
        flags.append('자기 자신까지 삭제한다는 표현은 완화한 전체 대안 제공')
    replacement = revised_target if key == '26-2' else ''
    combined = replacement or row['message'] + '\n\n' + supplement
    entry = dict(id=key, age=age, distance=distance, source_phase=row['phase'],
                 display_phase=names[age]['ko'], display_phase_en=names[age]['en'],
                 original_keyword=row['keyword'], proposed_keyword=name,
                 original_message=row['message'], supplement=supplement,
                 replacement_message=replacement, original_reason=row['reason'], flags=flags)
    entries.append(entry)
    draft = proposed_lookup[age, distance]
    draft['keyword'], draft['message'] = name, combined
manifest = {
    'title': '마이문 성향 150개 · 원문 검토와 보충 제안',
    'date': '2026-10-26', 'status': '검토용 제안 · 실제 앱 미반영',
    'source_sha256': hashlib.sha256(raw).hexdigest(),
    'method': '현재 앱: 달 황경 차 30구간 × 자정에서 떨어진 정도를 접어 만든 출생시각 5구간. 문안은 앱의 상징적 해석이며 과학적 성격 진단이나 전통 문헌의 고정된 150분류가 아님.',
    'time_groups': [
        '00:00–02:24 / 21:36–23:59', '02:25–04:48 / 19:13–21:35',
        '04:49–07:11 / 16:49–19:12', '07:12–09:36 / 14:24–16:48', '09:37–14:23'],
    'time_note': '한국시간, 분 단위 입력의 현재 JavaScript 계산 결과. 경계는 부동소수점 때문에 의도한 2시간24분 간격에서 1분씩 어긋나는 곳이 있음. 이번 검토에서는 계산 코드를 바꾸지 않음. 시간을 모르면 정오 기준인 4번 구간.',
    'duplicates': duplicates,
    'source_note': 'reason의 특정 저자 직접 인용·인도 티띠·음양론 연결은 출처 확인 전 상태로 보존. 이번 보충 문안은 책에서 발췌하지 않은 새 창작 문안.',
    'entries': entries
}
backup = ROOT / 'moon_messages.original.json'
if not backup.exists():
    backup.write_bytes(raw)
(ROOT / 'review-draft.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
(ROOT / 'moon_messages.proposed.json').write_text(json.dumps(proposed, ensure_ascii=False, indent=2), encoding='utf-8')
assert SOURCE.read_bytes() == raw
table = ['마이문 성향 이름 150개 — 현재 이름 → 제안 이름', '번호는 age 0~29 / 시각구간 0~4. 실제 앱은 바꾸지 않았습니다.', '']
for age in range(30):
    group = [e for e in entries if e['age'] == age]
    table.append(f"{age:02} | 앱: {group[0]['display_phase_en']} / {group[0]['display_phase']} | 원문: {group[0]['source_phase']}")
    table.extend(f"  {e['id']}  {e['original_keyword']} → {e['proposed_keyword']}" for e in group)
    table.append('')
(ROOT / '성향-이름-150개.txt').write_text('\n'.join(table), encoding='utf-8-sig')
report = f'''마이문 성향 문안 검토 — 2026-10-26

검토 범위: 150개 성향 원문, 30개 달 표기, 현재 출생시각 계산 코드.
원문 보존 SHA-256: {manifest['source_sha256']}
현재 앱 파일은 수정하지 않았습니다. review.html에서 비교·편집하고, 내보낸 JSON을 검토한 뒤 반영할 수 있습니다.

1. 분류는 30단계 × 5구간이 맞습니다.
시각은 실제 월출·월몰이나 상승궁이 아니라 자정에서 떨어진 정도를 기준으로 오전·오후를 접어 계산합니다. 대칭인 시각은 같은 distance를 가질 수 있습니다. 달 위상은 날짜와 시간으로 별도 계산하므로 실제 결과가 언제나 같다는 뜻은 아닙니다.
시간 경계는 review-draft.json의 time_groups를 참고하세요. 현재 코드의 부동소수점에 따른 1분 경계 차이가 있습니다. 이번에는 계산과 분류 규칙을 유지했습니다.

2. 원문의 장점
시작→성장→표현→나눔→성찰→비움이라는 흐름이 일관되고, 달이라는 소재와 다정한 말투가 잘 연결됩니다. 각 항목에 강점과 주의점을 함께 둔 구조도 유지할 가치가 있습니다.

3. 보충 방향
고요·내면·정돈·준비라는 표현이 여러 유형에 반복됩니다. 새 문안 150개는 일·관계·선택·표현에서 드러나는 구체적인 습관과 균형점을 더했습니다. 출생시각별 의미는 문안에서 읽힌 경향을 정리한 것으로 과학적·전통적 대응표가 아닙니다. 새 이름 후보도 150개를 각각 제안했습니다.

4. 성향과 운세 구분
곧·앞으로·머지않아 같은 미래 예고가 포함된 원문은 {sum('성향 글에 미래' in ' '.join(e['flags']) for e in entries)}개입니다. 보충 문안은 특정한 미래의 성취를 약속하기보다 반복되는 선택과 생활 장면을 설명합니다. 원문은 그대로 비교할 수 있도록 남겼습니다.

5. 이름 중복과 유사성
완전히 같은 이름: {json.dumps(duplicates,ensure_ascii=False)}.
정돈·정렬·정리, 숨은·보이지 않는·잠재된 이름은 뜻이 가까워 선택 화면에서 구분하기 어렵습니다. 후보명에는 행위와 장면을 넣어 차이를 드러냈습니다. 모든 후보는 검토용이며 앱에는 적용되지 않았습니다.

6. 달 이름 기준
메시지 내부 phase와 앱 표시 phase-names.json 사이에 다른 표기가 있습니다. 예: 26/2는 메시지에서 삭 전야, 앱에서 Dark Moon/신월직전입니다. 이름표와 천문 위상 구간은 별도로 정리하는 것이 좋습니다. 원문의 반달·보름 묘사가 현행 12도씩 나눈 위상 구간과 맞지 않는 부분도 있어 문안 확정 때 함께 점검해야 합니다.

7. 사진의 내적 정돈 (26-2)
후보명: 마음의 편집자. 기존의 자기 자신까지 삭제한다는 표현을 완화하고, 일의 우선순위·답변하기 전 필요한 시간·감정을 지우지 않는 균형을 담은 전체 대안을 제공했습니다.

8. 해석 이유(reason)의 출처
특정 저자가 이렇게 말했다는 문장과 티띠·음양론을 결합한 설명은 정확한 책·장·쪽을 확인한 인용으로 취급하지 않았습니다. 이번 작업에서 새로운 문헌의 권위를 붙이지 않았으며 reason은 원문 그대로 보존했습니다.

파일 안내
review.html: 원문·보충·이름을 비교하고 수정하는 편집 화면. 수정은 브라우저에 저장되며 JSON 내보내기로 별도 파일 저장.
review-draft.json: 원문과 후보, 보충 문안, 항목별 검토 메모.
moon_messages.proposed.json: 새 이름과 보충을 합친 앱 호환 제안본. 26-2만 전체 대안 적용. 현재 앱에는 반영하지 않음.
moon_messages.original.json: 시작 시점 원본 백업.
성향-이름-150개.txt: 현재 이름과 후보 이름 전체 목록.
'''
(ROOT / '검토-안내.txt').write_text(report, encoding='utf-8-sig')
template = (ROOT / 'review-template.html').read_text(encoding='utf-8')
payload = json.dumps(manifest, ensure_ascii=False).replace('<', '\\u003c')
source_payload = json.dumps(source, ensure_ascii=False).replace('<', '\\u003c')
(ROOT / 'review.html').write_text(template.replace('__REVIEW_DATA__', payload).replace('__SOURCE_DATA__', source_payload), encoding='utf-8')
assert len(set(e['proposed_keyword'] for e in entries)) == 150
print(json.dumps({'entries':len(entries),'unique_names':150,'source_unchanged':True,'future_prediction_entries':sum('성향 글에 미래' in ' '.join(e['flags']) for e in entries)},ensure_ascii=False))
