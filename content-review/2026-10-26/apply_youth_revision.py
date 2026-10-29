import copy, hashlib, json, pathlib, re

ROOT = pathlib.Path(__file__).resolve().parent
APP = ROOT.parents[1] / 'app'
source_path = APP / 'src/data/moon_messages.json'
original_path = ROOT / 'moon_messages.original.json'
original = json.loads(original_path.read_text(encoding='utf-8'))
previous = json.loads((ROOT / 'review-draft.json').read_text(encoding='utf-8'))
for filename in ('review-draft.json', 'review.html', 'review-template.html', 'moon_messages.proposed.json'):
    backup = ROOT / (filename + '.before-youth')
    if not backup.exists():
        backup.write_bytes((ROOT / filename).read_bytes())
if not (ROOT / 'moon_messages.pre-youth.json').exists():
    (ROOT / 'moon_messages.pre-youth.json').write_bytes(source_path.read_bytes())
youth = {}
for part in ('00-09', '10-19', '20-29'):
    youth.update(json.loads((ROOT / f'youth-{part}.json').read_text(encoding='utf-8')))
assert len(youth) == 150 and len(set(youth.values())) == 150
for key, text in youth.items():
    assert len(text) >= 130 and '\n\n' in text, key
    assert not any(word in text for word in ('회사', '업무', '생존력', '삭제해버', '누구보다', '독보적', '타고난', '반드시 성공')), key

reasons = [
    '아직 보이지 않는 달의 빛을 작은 시작에 빗대어 보았어요. 지금의 모습만으로 가능성을 정하지 않아도 된다는 마이문의 상징적 이야기예요.',
    '가느다란 빛이 나타나는 모습을 처음의 용기에 빗대어 보았어요. 낯설고 조심스러운 시작에도 의미를 남길 수 있어요.',
    '조금씩 자라는 달빛을 작은 경험이 쌓이는 모습에 빗대어 보았어요. 한 번에 큰 변화를 보여주지 않아도 괜찮아요.',
    '더 또렷해지는 달빛을 자신의 생각을 찾아가는 모습에 빗대어 보았어요. 생각은 다른 이야기를 들으며 바뀔 수도 있어요.',
    '차오르는 빛을 천천히 배우는 시간에 빗대어 보았어요. 남과 같은 속도로 자라야 하는 것은 아니에요.',
    '자리를 넓혀가는 달빛을 생각을 작은 표현으로 옮기는 모습에 빗대어 보았어요. 서툰 초안도 시작이 될 수 있어요.',
    '밝아지는 달의 경계를 망설임과 시도가 만나는 모습에 빗대어 보았어요. 조금 떨려도 작은 연습부터 해볼 수 있어요.',
    '빛의 모양이 또렷해지는 모습을 스스로 선택해보는 용기에 빗대어 보았어요. 도움을 받는 선택도 여기에 포함돼요.',
    '차오르는 달빛을 자신의 방법을 찾아보는 힘에 빗대어 보았어요. 혼자 배우는 시간과 함께 배우는 시간을 모두 가질 수 있어요.',
    '서로 다른 밝기와 모양을 여러 관점을 듣는 마음에 빗대어 보았어요. 자신의 의견도 다른 사람의 의견만큼 소중해요.',
    '넓어지는 빛을 조금씩 알아가는 즐거움에 빗대어 보았어요. 한 번의 결과보다 여러 경험을 통해 자신을 만나볼 수 있어요.',
    '퍼져가는 달빛을 마음을 나누는 모습에 빗대어 보았어요. 다른 사람에게 전한 관심을 자신에게도 돌려주세요.',
    '서로를 비추는 빛을 친구와 마음을 주고받는 모습에 빗대어 보았어요. 배려에는 자신의 마음을 지키는 일도 들어 있어요.',
    '가득 차오르는 빛을 좋아하는 것을 표현하는 열정에 빗대어 보았어요. 표현하는 방법은 천천히 배워가도 괜찮아요.',
    '둥글게 모이는 빛을 여러 모습을 함께 품는 마음에 빗대어 보았어요. 당신은 한 가지 기준으로만 설명되는 사람이 아니에요.',
    '보름을 지나 이어지는 달빛을 배운 것을 나누는 모습에 빗대어 보았어요. 나눔은 서로의 선택을 존중할 때 더 편안해질 수 있어요.',
    '서서히 달라지는 빛을 경험을 돌아보고 나누는 모습에 빗대어 보았어요. 서로 다른 경험에서도 배울 것을 찾아볼 수 있어요.',
    '조용히 달라지는 달의 모습을 마음을 들여다보는 시간에 빗대어 보았어요. 당장 설명하지 못하는 감정도 소중해요.',
    '기우는 달빛을 필요한 것과 어려운 것을 구분하는 모습에 빗대어 보았어요. 돌아볼 때 자신에게만 엄격할 필요는 없어요.',
    '줄어드는 빛을 활동을 마치고 여유를 남기는 모습에 빗대어 보았어요. 끝맺음 뒤에는 쉼도 함께할 수 있어요.',
    '빛을 덜어내는 달을 쉬어갈 공간을 만드는 모습에 빗대어 보았어요. 쉬기 위해 먼저 무엇을 증명할 필요는 없어요.',
    '가늘어지는 빛을 지나온 마음을 살피는 시간에 빗대어 보았어요. 아쉬움이 남아도 다음 경험을 만나볼 수 있어요.',
    '어둠 속에 남은 빛을 작은 변화를 알아차리는 관심에 빗대어 보았어요. 느낌은 사실과 함께 살피는 단서로 삼을 수 있어요.',
    '다음 주기를 향하는 달을 새롭게 배울 준비에 빗대어 보았어요. 준비가 다 끝나지 않아도 도움을 받으며 시작할 수 있어요.',
    '고요해지는 달빛을 자신의 이야기를 들어보는 시간에 빗대어 보았어요. 혼자 생각하는 힘과 기대는 힘을 함께 길러갈 수 있어요.',
    '조금 남은 빛을 필요한 것을 고르고 놓아주는 용기에 빗대어 보았어요. 아쉬움을 느끼면서도 자신에게 맞는 선택을 할 수 있어요.',
    '새로운 주기를 앞둔 달을 마음에 자리를 만드는 모습에 빗대어 보았어요. 정돈은 감정을 없애는 일이 아니라 소중한 것을 알아가는 일이에요.',
    '끝과 시작 사이의 달을 작은 변화가 자라는 시간에 빗대어 보았어요. 눈에 띄는 결과가 없어도 당신의 경험은 이어지고 있어요.',
    '빛이 쉬어가는 듯한 달을 자신을 돌보는 여유에 빗대어 보았어요. 늘 밝고 씩씩한 모습으로만 있어야 하는 것은 아니에요.',
    '다시 시작을 앞둔 달을 다음 걸음을 고르는 모습에 빗대어 보았어요. 당신의 이야기는 한 번의 선택으로 끝나지 않아요.'
]
active = copy.deepcopy(original)
active['meta']['introduction'] = '달은 차고 기울며 여러 모습을 보여줍니다. 마이문의 성향 글은 그 변화에 작은 용기와 쉼, 친구와의 관계, 자신을 알아가는 이야기를 담은 창작 문안입니다. 달이 당신의 성격이나 미래를 정하는 것은 아니에요. 마음에 닿는 부분을 가볍게 읽고 자신에게 맞는 방법을 찾아보세요.'
lookup = {(e['age'], e['distance']): e for e in previous['entries']}
entries = []
for group in active['messages']:
    for row in group:
        key = f"{row['age']:02}-{row['distance']}"
        row['message'] = youth[key]
        row['reason'] = reasons[row['age']]
        entry = copy.deepcopy(lookup[row['age'], row['distance']])
        entry['candidate_keyword'] = entry.get('candidate_keyword', entry['proposed_keyword'])
        entry['proposed_keyword'] = row['keyword']
        entry['supplement'] = ''
        entry['replacement_message'] = youth[key]
        entry['youth_reason'] = row['reason']
        entries.append(entry)
manifest = copy.deepcopy(previous)
manifest.update(title='마이문 성향 150개 · 청소년 성장 문안', status='청소년 성장 문안 · 앱 반영 완료', audience='청소년 · 성별에 따른 성격·역할 고정 없음', entries=entries,
    editorial_principles=['친구·과제·모둠 활동·취미 등 가까운 일상', '잘해야 한다는 압박보다 시도와 배움', '쉬기·거절하기·도움받기·생각 바꾸기도 성장', '성격·능력·미래를 단정하지 않는 존댓말', '성적·외모·인기를 개인의 가치와 분리', '이름과 30×5 분류는 유지'],
    source_note='왼쪽은 이전 원문, 오른쪽은 청소년 관점으로 전체를 다듬어 앱에 반영한 문안입니다. 이전 해석 이유의 인용은 비교용으로 보관했으며 앱에서는 쉬운 달의 상징 설명으로 바꿨습니다.')
source_bytes = (json.dumps(active, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
manifest['active_source_sha256'] = hashlib.sha256(source_bytes).hexdigest()
source_path.write_bytes(source_bytes)
(ROOT / 'moon_messages.youth.json').write_bytes(source_bytes)
(ROOT / 'moon_messages.proposed.json').write_bytes(source_bytes)
(ROOT / 'review-draft.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
template = (ROOT / 'review-template.html.before-youth').read_text(encoding='utf-8')
template = template.replace('mealuna-editorial-2026-10-26-v1','mealuna-editorial-2026-10-26-youth-v2')
template = template.replace('검토용 제안 · 현재 앱 원문 유지','청소년 성장 문안 · 앱 반영 완료')
template = template.replace('나의 달, 나의 성향 · 150개 문안 검토','나의 달, 나의 성향 · 청소년 성장 문안 150개')
template = template.replace('현재 이름과 새 후보를 비교하고, 보충 문안을 직접 다듬어보세요.','이름은 그대로 두고 친구·배움·작은 도전과 쉼을 중심으로 다듬었습니다. 원문과 비교해보세요.')
template = template.replace('원문의 달 이미지와 다정한 말투를 유지하고, 보충에는 구체적인 일·관계·선택 장면을 넣었습니다.','달의 분위기를 살리고 친구·모둠 활동·과제·취미 등 가까운 일상으로 다듬었습니다.')
template = template.replace('새 이름 후보는 모두 검토용입니다.','이름은 기존 그대로 유지했고 예전 이름 후보는 참고용으로 남겼습니다.')
template = template.replace('보충 문안은 책에서 발췌하지 않은 새 창작 문안입니다.','현재 앱에서는 해당 설명을 쉬운 달의 상징 이야기로 바꿨습니다. 새 문안은 책에서 발췌하지 않은 창작 문안입니다.')
template = template.replace('진한 글씨는 현재 이름, 아래는 수정 가능한 후보입니다. 이름을 누르면 해당 성향 글로 이동합니다.','진한 글씨는 유지한 이름이고 아래는 이전에 제안했던 참고 후보입니다. 이름을 누르면 청소년 문안을 볼 수 있어요.')
template = template.replace('→ ${escape(e.proposed_keyword)}</span></button>','참고 후보: ${escape(e.candidate_keyword||e.proposed_keyword)}</span></button>')
template = template.replace('<h3>${escape(e.original_keyword)} <small>→ ${escape(e.proposed_keyword)}</small></h3>','<h3>${escape(e.proposed_keyword)}</h3>')
template = template.replace('<b>기존 원문</b>','<b>이전 원문 · 비교용</b>')
template = template.replace('이름 후보<input','성향 이름 (기존 유지)<input')
template = template.replace('<label>보충 문안<textarea data-id="${e.id}" data-field="supplement">${escape(e.supplement)}</textarea></label>','<label>청소년을 위한 성향 문안<textarea class="replacement" data-id="${e.id}" data-field="replacement_message">${escape(e.replacement_message)}</textarea></label>')
template, count = re.subn(r"\$\{e\.id==='26-2'\?.*?:''\}", '', template)
assert count == 1
template = template.replace('보충은 기존 글 뒤에 붙입니다. 26-2는 전체 대안이 입력되어 있으면 대안을 우선 내보냅니다.','이 문안은 이전 원문을 대신합니다. 이름은 기존 이름을 유지했습니다. 이 화면에서 편집한 내용은 JSON으로 저장해야 앱에 다시 반영할 수 있습니다.')
template = template.replace('합친 제안문 미리보기','현재 제안문 미리보기')
(ROOT / 'review-template-youth.html').write_text(template, encoding='utf-8')
payload = json.dumps(manifest, ensure_ascii=False).replace('<','\\u003c')
source_payload = json.dumps(active, ensure_ascii=False).replace('<','\\u003c')
(ROOT / 'review.html').write_text(template.replace('__REVIEW_DATA__',payload).replace('__SOURCE_DATA__',source_payload), encoding='utf-8')
(ROOT / '청소년-문안-반영.txt').write_text('청소년 관점 문안 150개를 앱에 반영했습니다.\n기존 성향 이름·달 이름·30×5 분류·운세 240개는 유지했습니다.\n공부·친구·취미·모둠 활동의 작은 장면, 자기 존중, 쉬기와 도움받기를 담았습니다.\n이전 원문은 moon_messages.original.json, 이전 검토본은 .before-youth 파일에 보관했습니다.\n현재 문안은 moon_messages.youth.json이며 review.html에서 비교할 수 있습니다.\n검토 화면의 이전 브라우저 편집은 v1 저장 공간에 남겨두고 새 문안은 별도 저장 공간을 사용합니다.\n', encoding='utf-8-sig')
base_rows = [r for g in original['messages'] for r in g]
active_rows = [r for g in active['messages'] for r in g]
assert [(r['age'],r['distance'],r['phase'],r['keyword']) for r in base_rows] == [(r['age'],r['distance'],r['phase'],r['keyword']) for r in active_rows]
assert len(active_rows) == 150
print(json.dumps({'rewritten':150,'names_and_classification_unchanged':True,'backup_preserved':True,'review_updated':True}, ensure_ascii=False))
