import {shareText,type ShareContent} from './sharing';
import * as sdk from '@apps-in-toss/web-framework';
import {save} from './storage';
export function inToss(){try{const environment=sdk.getOperationalEnvironment();return environment==='toss'||environment==='sandbox'}catch{return false}}
export async function identify(){if(!inToss())return;try{const key=await sdk.User.getAnonymousKey();save('anonymous-key',key)}catch{/* Unsupported older hosts must not prevent moon browsing. */}}
export async function currentLocation(){if(inToss()){const permission=await sdk.Device.getLocation.getPermission();if(permission!=='allowed'){await sdk.Device.getLocation.openPermissionDialog()}const location=await sdk.Device.getLocation({accuracy:sdk.Accuracy.Balanced});return location.coords}return await new Promise<GeolocationCoordinates>((resolve,reject)=>{if(!navigator.geolocation){reject(new Error('위치 기능을 지원하지 않아요. 지역을 직접 선택해 주세요.'));return}navigator.geolocation.getCurrentPosition(p=>resolve(p.coords),()=>reject(new Error('위치를 가져오지 못했어요. 지역을 직접 선택해 주세요.')),{timeout:12000,maximumAge:300000,enableHighAccuracy:false})})}
let rewardReady:Promise<void>|undefined;
export function prepareRewardedAd():Promise<void>{
  if(rewardReady)return rewardReady;
  const id=import.meta.env.VITE_REWARDED_AD_GROUP_ID?.trim();
  if(!id||!inToss()||!sdk.loadFullScreenAd.isSupported())return Promise.reject(new Error('광고를 지원하는 최신 토스 앱에서 이용해 주세요.'));
  rewardReady=new Promise<void>((resolve,reject)=>{
    let cleanup=()=>{};let settled=false;
    const timer=setTimeout(()=>finish(new Error('광고를 불러오지 못했어요. 다시 시도해 주세요.')),20000);
    function finish(error?:Error){if(settled)return;settled=true;clearTimeout(timer);queueMicrotask(()=>cleanup());error?reject(error):resolve()}
    cleanup=sdk.loadFullScreenAd({options:{adGroupId:id},onEvent:e=>{if(e.type==='loaded')finish()},onError:()=>finish(new Error('광고를 불러오지 못했어요. 다시 시도해 주세요.'))});
  }).catch(error=>{rewardReady=undefined;throw error});
  return rewardReady;
}
export async function watchRewardedAd():Promise<void>{
  if(!inToss()||!sdk.showFullScreenAd.isSupported())throw new Error('광고를 지원하는 최신 토스 앱에서 이용해 주세요.');
  await prepareRewardedAd();
  rewardReady=undefined;
  const id=import.meta.env.VITE_REWARDED_AD_GROUP_ID.trim();
  await new Promise<void>((resolve,reject)=>{
    let cleanup=()=>{};let settled=false;
    const timer=setTimeout(()=>finish(new Error('광고 시청 완료를 확인하지 못했어요. 다시 시도해 주세요.')),300000);
    function finish(error?:Error){if(settled)return;settled=true;clearTimeout(timer);queueMicrotask(()=>cleanup());error?reject(error):resolve()}
    cleanup=sdk.showFullScreenAd({options:{adGroupId:id},onEvent:e=>{
      if(e.type==='userEarnedReward')finish();
      else if(e.type==='dismissed')finish(new Error('광고를 끝까지 시청하면 오늘의 운세가 열려요.'));
      else if(e.type==='failedToShow')finish(new Error('광고를 표시하지 못했어요. 다시 시도해 주세요.'));
    },onError:()=>finish(new Error('광고를 표시하지 못했어요. 다시 시도해 주세요.'))});
  });
}
export async function shareMessage(content:ShareContent):Promise<'shared'|'copied'>{
 const appName=import.meta.env.VITE_APP_NAME?.trim()||'mea-luna';
 const path=`intoss://${appName}?entry=${content.kind}`;
 // Native Toss creates an HTTPS app link; web previews use the app scheme, never localhost.
 const url=inToss()?await sdk.Share.createLink({path,ogImageUrl:'https://raw.githubusercontent.com/Sanghyug/myMoon/main/app/public/assets/images/mealuna_logo.png'}):path;
 const text=shareText(content,url);
 if(inToss()){await sdk.Share.sendMessage({message:text});return 'shared'}
 if(navigator.share){await navigator.share({title:content.title,text});return 'shared'}
 await navigator.clipboard.writeText(text);return 'copied';
}


export function subscribeBack(callback:()=>boolean){if(!inToss())return ()=>{};return sdk.graniteEvent.addEventListener('backEvent',{onEvent:()=>{if(!callback())void sdk.Screen.close()}})}

export function sharedEntry(){try{const url=inToss()?sdk.Environment.initialURL:window.location.href;const entry=new URL(url).searchParams.get('entry');return entry==='fortune'?'fortune':'personality'}catch{return 'personality'}}
