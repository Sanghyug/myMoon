import {defineConfig} from '@apps-in-toss/web-framework/config';
import {loadEnv} from 'vite';
const env=loadEnv('production',process.cwd(),'');
export default defineConfig({appName:env.VITE_APP_NAME||'mea-luna',brand:{primaryColor:'#70508D'},permissions:[{name:'geolocation',access:'access'},{name:'clipboard',access:'write'}],navigationBar:{withBackButton:true,withHomeButton:false,withTitle:true,theme:'light'},webView:{bounces:false,pullToRefreshEnabled:false,overScrollMode:'never'},webBundleDir:'dist'});
