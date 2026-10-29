import React from 'react';
import {createRoot} from 'react-dom/client';
import {App} from './App';
import './style.css';
import {PlatformProvider} from './ui';
createRoot(document.getElementById('root')!).render(<React.StrictMode><PlatformProvider><App/></PlatformProvider></React.StrictMode>);
