import {useMemo,useId} from 'react';
import {clock,dayKey,dayStart,position,type Place} from './astronomy';

/** A full Korean calendar day, including the Moon below the horizon. */
export function MoonPath({now,place,rise,set}:{now:Date;place:Place;rise:Date|null;set:Date|null}){
  const id=useId().replaceAll(':','');
  const start=dayStart(now);
  const points=useMemo(()=>Array.from({length:145},(_,i)=>{
    const date=new Date(start.getTime()+i*600000);
    return {hour:i/6,altitude:position(date,place).altitude};
  }),[dayKey(now),place]);
  const x=(hour:number)=>34+hour/24*306;
  const y=(altitude:number)=>84-altitude/90*66;
  const curve=points.map((p,i)=>`${i?'L':'M'}${x(p.hour).toFixed(2)},${y(p.altitude).toFixed(2)}`).join(' ');
  const current=position(now,place);
  const currentX=x((now.getTime()-start.getTime())/3600000);
  const currentY=y(current.altitude);
  return <div className="moon-path">
    <div className="moon-path-heading"><span>오늘 달의 움직임</span><span>현재 {clock(now)}</span></div>
    <svg viewBox="0 0 360 185" role="img" aria-label={`${place.name}의 오늘 0시부터 24시까지 달의 고도. 현재 고도 ${current.altitude.toFixed(0)}도, ${current.altitude>=0?'지평선 위':'지평선 아래'}.`}>
      <defs><clipPath id={`${id}-above`}><rect x="34" y="16" width="306" height="68"/></clipPath><clipPath id={`${id}-below`}><rect x="34" y="84" width="306" height="68"/></clipPath></defs>
      {[60,0,-60].map(alt=><g key={alt}><line x1="34" x2="340" y1={y(alt)} y2={y(alt)} stroke={alt===0?'#84738e':'#ffffff12'} strokeDasharray={alt===0?'4 4':undefined}/><text x="26" y={y(alt)+4} textAnchor="end" fill="#bbb1c6" fontSize="11">{alt>0?'+':''}{alt}°</text></g>)}
      <path d={curve} fill="none" stroke="#f3eafc" strokeWidth="2.5" clipPath={`url(#${id}-above)`}/>
      <path d={curve} fill="none" stroke="#887798" strokeWidth="2" strokeDasharray="4 4" clipPath={`url(#${id}-below)`}/>
      <line x1={currentX} x2={currentX} y1="16" y2="151" stroke="#c3a1de" strokeDasharray="3 4"/>
      <circle cx={currentX} cy={currentY} r="4" fill="#edcffc" stroke="#000" strokeWidth="2"/>
      {[rise,set].map((date,i)=>date&&<circle key={i} cx={x((date.getTime()-start.getTime())/3600000)} cy={84} r="3" fill="#d4b77e"><title>{i===0?'월출':'월몰'} {clock(date)}</title></circle>)}
      {[0,6,12,18,24].map(hour=><g key={hour}><line x1={x(hour)} x2={x(hour)} y1="151" y2="155" stroke="#76657f"/><text x={x(hour)} y="174" textAnchor="middle" fill="#bbb1c6" fontSize="11">{hour}시</text></g>)}
    </svg>
    <p>실선: 지평선 위 · 점선: 지평선 아래 · 보라색 점: 현재</p>
  </div>;
}
