// Some restricted Windows runners cannot query the OS account. This compatibility
// fallback affects only the test runner's temporary-directory selection.
import os from 'node:os';
const userInfo=os.userInfo;
os.userInfo=function(...args){try{return userInfo.apply(os,args)}catch(error){if(error.code!=='ERR_SYSTEM_ERROR')throw error;return {username:'mealuna-tests',uid:-1,gid:-1,homedir:process.cwd(),shell:null}}};
