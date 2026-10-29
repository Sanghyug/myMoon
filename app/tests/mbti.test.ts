import {test} from 'node:test';
import assert from 'node:assert/strict';
import {originalMessages} from '../src/content';
import {storyMbti} from '../src/mbti';
import {readFileSync} from 'node:fs';

test('expanded stories retain unique summaries and add strengths, pitfalls and exercises',()=>{
 const previous=JSON.parse(readFileSync(new URL('../../content-review/2026-10-28/moon_messages.before-expansion.json',import.meta.url),'utf8')).messages.flat();
 for(const message of originalMessages){
  const old=previous.find((m:{age:number;distance:number})=>m.age===message.age&&m.distance===message.distance);
  assert.ok(message.message.length>=old.message.length*2);
  const [summary,...rest]=message.message.split('\n\n');
  assert.ok(!rest.join('\n').includes(summary));
  for(const label of ['장점 ·','주의할 점 ·','오늘의 실천\n'])assert.ok(message.message.includes(label));
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
