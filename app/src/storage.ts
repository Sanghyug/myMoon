export function readSaved<T>(key:string,fallback:T):T{try{const value=localStorage.getItem('mealuna:'+key);return value===null?fallback:JSON.parse(value)}catch{return fallback}}
export function save(key:string,value:unknown){try{localStorage.setItem('mealuna:'+key,JSON.stringify(value));return true}catch{return false}}
export function remove(key:string){try{localStorage.removeItem('mealuna:'+key)}catch{/* Session remains usable without local storage. */}}
