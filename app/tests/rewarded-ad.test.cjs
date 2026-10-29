const {test}=require('node:test');
const assert=require('node:assert/strict');
const vm=require('node:vm');
const ts=require('typescript');
const fs=require('node:fs');
function setup(){
 let load,show,loads=0;
 const sdk={getOperationalEnvironment:()=> 'toss',loadFullScreenAd:Object.assign(p=>{loads++;load=p;return()=>{}},{isSupported:()=>true}),showFullScreenAd:Object.assign(p=>{show=p;return()=>{}},{isSupported:()=>true})};
 const source=fs.readFileSync('src/platform.ts','utf8').replaceAll('import.meta.env.VITE_REWARDED_AD_GROUP_ID',JSON.stringify('test-reward')).replaceAll('import.meta.env.VITE_APP_NAME',JSON.stringify('mea-luna'));
 const code=ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText;
 const context={exports:{},require:n=>n==='./storage'?{save:()=>{}}:sdk,setTimeout,clearTimeout,queueMicrotask};
 vm.runInNewContext(code,context);
 return {api:context.exports,get load(){return load},get show(){return show},get loads(){return loads}};
}
test('preload is shared; reward completion unlocks only once',async()=>{
 const s=setup();const preload=s.api.prepareRewardedAd();assert.equal(s.api.prepareRewardedAd(),preload);s.load.onEvent({type:'loaded'});await preload;
 let earned=false;const watching=s.api.watchRewardedAd().then(()=>{earned=true});await new Promise(setImmediate);
 assert.equal(s.loads,1);s.show.onEvent({type:'impression'});await Promise.resolve();assert.equal(earned,false);
 s.show.onEvent({type:'userEarnedReward'});s.show.onEvent({type:'dismissed'});await watching;assert.equal(earned,true);
 const next=s.api.prepareRewardedAd();assert.equal(s.loads,2);s.load.onEvent({type:'loaded'});await next;
});
test('dismissal and display failure never grant reward',async()=>{
 for(const type of ['dismissed','failedToShow']){const s=setup();const p=s.api.watchRewardedAd();s.load.onEvent({type:'loaded'});await new Promise(setImmediate);s.show.onEvent({type});await assert.rejects(p);}
});
test('load failure allows a later retry',async()=>{
 const s=setup();const p=s.api.prepareRewardedAd();s.load.onError(new Error('offline'));await assert.rejects(p);
 const retry=s.api.prepareRewardedAd();assert.equal(s.loads,2);s.load.onEvent({type:'loaded'});await retry;
});
