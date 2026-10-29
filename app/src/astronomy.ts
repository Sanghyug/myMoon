import {Body,Observer,MoonPhase,Illumination,Equator,Horizon,SearchRiseSet} from 'astronomy-engine';
export type Place={name:string;latitude:number;longitude:number};
export const cities:Place[]=[{name:'서울',latitude:37.5665,longitude:126.978},{name:'부산',latitude:35.1796,longitude:129.0756},{name:'대구',latitude:35.8714,longitude:128.6014},{name:'인천',latitude:37.4563,longitude:126.7052},{name:'광주',latitude:35.1595,longitude:126.8526},{name:'대전',latitude:36.3504,longitude:127.3845},{name:'제주',latitude:33.4996,longitude:126.5312},{name:'강릉',latitude:37.7519,longitude:128.8761}];
export const KST=9*3600000;
export function dayKey(date:Date){return new Date(date.getTime()+KST).toISOString().slice(0,10)}
export function kstDate(day:string,time='12:00'){const d=new Date(`${day}T${time}:00+09:00`);if(!Number.isFinite(d.getTime()))throw new Error('날짜와 시간을 확인해 주세요.');return d}
export function dayStart(date:Date){return kstDate(dayKey(date),'00:00')}
export function clock(date:Date|null){return date?new Intl.DateTimeFormat('ko-KR',{timeZone:'Asia/Seoul',hour:'2-digit',minute:'2-digit',hour12:false}).format(date):'오늘 없음'}
export function phaseIndex(date:Date){return Math.min(29,Math.floor(MoonPhase(date)/12))}
export function physicalPhase(phase:number){if(phase<6||phase>=354)return '신월';if(phase<84)return '초승달';if(phase<96)return '상현달';if(phase<174)return '차오르는 달';if(phase<186)return '보름달';if(phase<264)return '기우는 달';if(phase<276)return '하현달';return '그믐달'}
export function position(date:Date,place:Place){const observer=new Observer(place.latitude,place.longitude,0);const eq=Equator(Body.Moon,date,observer,true,true);const h=Horizon(date,observer,eq.ra,eq.dec,'normal');return {altitude:h.altitude,azimuth:h.azimuth}}
export function moonAt(date:Date,place:Place){const phase=MoonPhase(date);return {phase,index:phaseIndex(date),illumination:Illumination(Body.Moon,date).phase_fraction*100,name:physicalPhase(phase),...position(date,place)}}
export function riseSet(date:Date,place:Place){const observer=new Observer(place.latitude,place.longitude,0);const start=dayStart(date);const end=start.getTime()+86400000;const rise=SearchRiseSet(Body.Moon,observer,1,start,1)?.date??null;const set=SearchRiseSet(Body.Moon,observer,-1,start,1)?.date??null;const nextRise=SearchRiseSet(Body.Moon,observer,1,date,3)?.date??null;return {rise:rise&&rise.getTime()<end?rise:null,set:set&&set.getTime()<end?set:null,nextRise}}
export function direction(az:number){return ['북','북동','동','남동','남','남서','서','북서'][Math.round(az/45)%8]}
export function relativeBearing(target:number,heading:number){return ((target-heading+540)%360)-180}
