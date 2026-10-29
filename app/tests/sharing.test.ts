import {test} from 'node:test';
import assert from 'node:assert/strict';
import {birthContent} from '../src/content';
import {makeShareContent,shareText} from '../src/sharing';
test('personality and fortune sharing stay separate after fortune is unlocked',()=>{
 const birth={day:'2003-10-15',time:'03:30',unknownTime:false};
 const self=birthContent(birth);const fortune='운세만 공유하는 고유한 문장입니다.';
 const personality=makeShareContent('personality',self,fortune,'2026-10-29');
 const daily=makeShareContent('fortune',self,fortune,'2026-10-29');
 assert.ok(personality.body.length>100);assert.ok(!personality.body.includes(fortune));
 assert.equal(daily.body,fortune);assert.notEqual(personality.title,daily.title);
 for(const card of [personality,daily]){
  const text=shareText(card,'https://example.com/app');
  assert.ok(text.includes('https://example.com/app'));
  assert.ok(!text.includes(birth.day));assert.ok(!text.includes(birth.time));
 }
});
