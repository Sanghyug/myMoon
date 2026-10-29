import {test} from 'node:test';
import assert from 'node:assert/strict';
import {originalMessages} from '../src/content';
import {storyMbti} from '../src/mbti';
import {readFileSync} from 'node:fs';

test('guardian stories describe enduring traits without daily exercises',()=>{
 assert.equal(new Set(originalMessages.map(m=>m.guardian)).size,30);
 assert.equal(new Set(originalMessages.map(m=>m.message)).size,150);
 for(const message of originalMessages){
  assert.ok(message.guardian.length>=3);
  assert.ok(message.message.includes('나의 장점\n'));
  assert.ok(message.message.includes('주의할 점\n'));
  assert.doesNotMatch(message.message,/오늘의 실천|이번 한 주|일주일 뒤/);
 }
});

test('all 150 story variants have a readable editorial MBTI analogy',()=>{
 for(const message of originalMessages){
  const analogy=storyMbti(message);
  assert.match(analogy.type,/^[IE][NS][FT][JP]$/);
  assert.ok(analogy.theme.length>0);
  assert.ok(analogy.description.length>30);
 }
});
test('analogies follow individual story themes within the same moon group',()=>{
 const preparation=originalMessages.find(m=>m.age===1&&m.distance===2)!;
 const kindness=originalMessages.find(m=>m.age===1&&m.distance===4)!;
 assert.equal(storyMbti(preparation).type,'ISTJ');
 assert.equal(storyMbti(kindness).type,'ISFJ');
 assert.throws(()=>storyMbti({age:30,distance:0,message:''}));
});
