import {Button as TDSButton} from '@toss/tds-mobile';
import {TDSMobileAITProvider} from '@toss/tds-mobile-ait';
import type {ButtonHTMLAttributes,ReactNode} from 'react';
import {inToss} from './platform';
export function AppButton({className,children,...props}:ButtonHTMLAttributes<HTMLButtonElement>){if(inToss()&&className==='primary')return <div className="tds-action"><TDSButton color="primary" display="block" size="large" type={props.type??'button'} disabled={props.disabled} onClick={props.onClick}>{children}</TDSButton></div>;return <button className={className} {...props}>{children}</button>}
export function PlatformProvider({children}:{children:ReactNode}){return inToss()?<TDSMobileAITProvider brandPrimaryColor="#70508D">{children}</TDSMobileAITProvider>:<>{children}</>}
