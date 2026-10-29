import messages from './data/moon_messages.json';
import fortunes from './data/moon_fortune_8x30.json';
import names from './data/phase-names.json';
import {phaseIndex,kstDate,dayKey} from './astronomy';
export type Birth={day:string;time:string;unknownTime:boolean};
export const originalMessages=messages.messages.flat();
export const originalFortunes=fortunes;
export const phaseNames=names;
// The original type 2 repeats phases 0..9 in positions 10..19. Preserve the
// source bytes and prose, and repair only those lookup keys in memory.
export function fortuneFor(userType:number,index:number){const group=fortunes.filter(f=>f.user_type===userType);const item=group.find(f=>f.today_phase===index)??(userType===2&&index>=10&&index<=19?group[index]:undefined);if(!item)throw new Error('오늘의 운세 데이터를 찾을 수 없어요.');return item.fortune}
export function birthContent(birth:Birth){const time=birth.unknownTime?'12:00':birth.time;const date=kstDate(birth.day,time);const age=phaseIndex(date);const [hour,minute]=time.split(':').map(Number);const h=hour+minute/60;const distance=Math.min(4,Math.floor((h<=12?h:24-h)/12*5));const message=originalMessages.find(x=>x.age===age&&x.distance===distance);if(!message)throw new Error('이 달의 성향 데이터를 찾을 수 없어요.');return {age,distance,date,message,name:phaseNames[age]}}
export function dailyFortune(birth:Birth,now:Date){const {age}=birthContent(birth);const userType=Math.min(7,Math.floor(age*8/30));return fortuneFor(userType,phaseIndex(kstDate(dayKey(now))))}
export function unlockKey(birth:Birth,now:Date){return `${dayKey(now)}:${birth.day}:${birth.unknownTime?'unknown':birth.time}`}
