import {useEffect,useRef,useState} from 'react';
import {TossAds} from '@apps-in-toss/web-framework';
import {inToss} from './platform';

// A single inline slot, kept separate from content buttons and fortune access.
export function BannerAd(){
  const target=useRef<HTMLDivElement>(null);
  const [rendered,setRendered]=useState(false);
  const id=import.meta.env.VITE_BANNER_AD_GROUP_ID?.trim();
  useEffect(()=>{
    if(!id||!target.current||!inToss()||!TossAds.initialize.isSupported()||!TossAds.attachBanner.isSupported())return;
    let disposed=false;
    let slot:ReturnType<typeof TossAds.attachBanner>|undefined;
    TossAds.initialize({callbacks:{
      onInitialized:()=>{
        if(disposed||!target.current)return;
        slot=TossAds.attachBanner(id,target.current,{theme:'light',variant:'card',callbacks:{
          onAdRendered:()=>{if(!disposed)setRendered(true)},
          onAdFailedToRender:()=>{if(!disposed)setRendered(false)},
        }});
      },
      onInitializationFailed:()=>{if(!disposed)setRendered(false)},
    }});
    return()=>{disposed=true;slot?.destroy()};
  },[id]);
  return <aside className={`banner-ad${rendered?' is-rendered':''}`} aria-label="광고"><div ref={target}/></aside>;
}
