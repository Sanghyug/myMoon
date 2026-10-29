import type {birthContent} from './content';
export type ShareKind='personality'|'fortune';
export type ShareContent={kind:ShareKind;title:string;body:string;phase:string;age:number};
export function makeShareContent(kind:ShareKind,self:ReturnType<typeof birthContent>,fortune:string,day:string):ShareContent{
 const intro=self.message.message.split('\n\n')[0].split('\n').slice(1).join('\n');
 return {kind,title:kind==='personality'?self.message.guardian:`${day.replaceAll('-','.')} 달의 속삭임`,body:kind==='personality'?intro:fortune,phase:`${self.name.en} · ${self.name.ko}`,age:self.age};
}
export function shareText(content:ShareContent,url:string){return `${content.kind==='personality'?'☾ 나의 수호월과 성향':'☾ 오늘의 운세 · 달의 속삭임'}\n\n${content.title}\n${content.phase}\n\n${content.body}\n\n나의 달 · Mea Luna\n나의 달 만나러 가기\n${url}`}

export async function saveShareCard(content:ShareContent){
 await document.fonts.ready;
 const canvas=document.createElement('canvas');canvas.width=1080;
 const ctx=canvas.getContext('2d');if(!ctx)throw new Error('이미지를 만들 수 없어요.');
 function lines(text:string,font:string,width:number){ctx!.font=font;const result:string[]=[];for(const paragraph of text.split('\n')){let line='';for(const character of paragraph){if(ctx!.measureText(line+character).width>width&&line){result.push(line);line=character}else line+=character}result.push(line)}return result}
 const body=lines(content.body,'32px sans-serif',864);canvas.height=740+body.length*56;
 const background=ctx.createLinearGradient(0,0,1080,canvas.height);background.addColorStop(0,'#30213f');background.addColorStop(1,'#100d18');ctx.fillStyle=background;ctx.fillRect(0,0,1080,canvas.height);
 const image=new Image();image.src=`/assets/moon_phases/moon_${String(content.age).padStart(2,'0')}.png`;await image.decode();ctx.save();ctx.beginPath();ctx.arc(540,225,120,0,Math.PI*2);ctx.clip();ctx.drawImage(image,420,105,240,240);ctx.restore();
 ctx.textAlign='center';ctx.fillStyle='#d3b678';ctx.font='22px sans-serif';ctx.fillText(content.kind==='personality'?'MY GUARDIAN MOON':'WHISPER OF MOON',540,65);
 ctx.fillStyle='#f3eaf9';ctx.font='bold 48px sans-serif';ctx.fillText(content.title,540,430,900);ctx.fillStyle='#cbb4dc';ctx.font='26px sans-serif';ctx.fillText(content.phase,540,485);
 ctx.textAlign='left';ctx.fillStyle='#f3eaf9';ctx.font='32px sans-serif';body.forEach((line,i)=>ctx.fillText(line,108,580+i*56));ctx.textAlign='center';ctx.fillStyle='#d3b678';ctx.font='27px sans-serif';ctx.fillText('나의 달 · Mea Luna',540,canvas.height-65);
 const blob=await new Promise<Blob>((resolve,reject)=>canvas.toBlob(b=>b?resolve(b):reject(new Error('이미지 생성에 실패했어요.')),'image/png'));
 const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download=`mea-luna-${content.kind}.png`;a.click();setTimeout(()=>URL.revokeObjectURL(url),60000);
}
