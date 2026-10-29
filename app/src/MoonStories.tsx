import {ChevronDown} from 'lucide-react';
import type {ReactNode} from 'react';

function Figure({name,alt,caption,width,height}:{name:string;alt:string;caption:ReactNode;width:number;height:number}){
 return <figure className="moon-story-figure"><img src={`/assets/moon-stories/${name}.webp`} alt={alt} width={width} height={height} loading="lazy"/><figcaption>{caption}</figcaption></figure>;
}
function Source({href,children}:{href:string;children:ReactNode}){return <a href={href} target="_blank" rel="noopener noreferrer">{children}<span className="sr-only"> (새 창)</span></a>}

const stories=[
 {title:'외로운 지구, 더 외로운 달',subtitle:'가까워 보이는 달까지, 사실은 얼마나 멀까요?',body:<>
  <p>커다란 지구 옆에 달이 바짝 붙어 있는 그림을 본 적 있나요? 한 화면에 담기 위해 크기와 거리를 조절한 그림에 익숙해지면, 달이 생각보다 가까이 있다고 느끼기 쉬워요. 하지만 실제 우주에는 두 천체 사이를 채우는 넓은 빈 공간이 있어요.</p>
  <p>지구와 달의 중심 사이 평균 거리는 약 <strong>384,400km</strong>예요. 지구 지름을 약 30개 이어 놓을 수 있는 거리이지요. 달의 궤도는 타원이어서 이 거리는 늘 같지는 않아요.</p>
  <Figure name="juno-earth-moon" width={685} height={386} alt="검은 우주를 사이에 두고 왼쪽에 작게 보이는 지구, 오른쪽에 더 작게 보이는 달" caption={<>2011년 8월 26일, 목성으로 향하던 주노가 지구에서 약 966만km 떨어져 촬영한 모습이에요. 왼쪽이 지구, 오른쪽이 달입니다.<br/>NASA/JPL-Caltech/SwRI/MSSS · 제공 자료 수록 이미지</>}/>
  <p>사진 속 두 점을 바라보면 우리가 사는 지구도, 늘 익숙하게 올려다보던 달도 새롭게 느껴져요. 가까운 친구처럼 보이던 달은 저만큼의 거리를 두고 지구와 함께 태양 주위를 여행하고 있어요.</p>
  <div className="moon-science-note"><h4>손안의 크기로 줄여보면</h4><p>지구를 지름 0.85mm의 작은 알갱이로 줄이면 달은 약 0.23mm예요. 두 알갱이의 중심은 약 2.6cm 떨어져 있어야 해요. 같은 비율에서 태양은 지름 약 9.3cm, 지구에서 약 10m 떨어진 곳에 놓입니다. 평균 거리와 지름으로 환산한 비유예요.</p></div>
  <p className="moon-story-sources">더 알아보기 · <Source href="https://science.nasa.gov/moon/facts/">NASA 달의 거리와 크기</Source> · <Source href="https://www.jpl.nasa.gov/images/pia18427-junos-post-launch-view-of-earth-and-moon/">주노 사진의 이야기</Source></p>
 </>},
 {title:'너의 달',subtitle:'길을 걸으면 달도 나를 따라오는 것 같아요.',body:<>
  <blockquote><p>“아빠, 달이 따라와.”<br/>등에 매달린 딸이 말했다.<br/>나는 돌아가신 어머니를 떠올리며 대답했다.<br/>“응, 너의 달이니까.”</p><cite>원작 ‘너의 달’ 중에서</cite></blockquote>
  <Figure name="your-moon" width={1024} height={1024} alt="차창 밖으로 밝은 달을 바라보는 아이의 일러스트" caption="어디에 가도 함께하는 것처럼 느껴지는 달. 원작 자료의 일러스트예요."/>
  <p>걷거나 차를 타고 이동할 때, 달이 계속 내 옆에 있는 듯 느껴진 적 있나요? 이 다정한 착각에는 달이 아주 멀리 있다는 과학적인 이유가 숨어 있어요.</p>
  <p>달리는 열차의 창밖을 떠올려보세요. 가까운 전봇대와 나무는 빠르게 스쳐 가지만, 먼 산은 한참 동안 창밖에 남아 있지요. 내가 이동할 때 바라보는 방향이 달라지는 정도는 물체까지의 거리에 따라 달라져요. 가까운 물체일수록 방향 변화가 크고, 먼 물체일수록 작습니다. 관찰 위치에 따라 물체의 겉보기 위치가 달라지는 현상을 <strong>시차</strong>라고 해요.</p>
  <Figure name="train-window" width={1024} height={1024} alt="기차 창밖의 가까운 전봇대와 멀리 이어지는 숲과 산" caption="같은 거리를 이동해도 가까운 풍경과 먼 풍경은 서로 다른 속도로 지나가는 듯 보여요. 원작 자료의 이미지예요."/>
  <p>달은 먼 산보다도 훨씬 멀리 있어요. 달까지의 거리를 평균값으로 두고, 시선에 수직인 방향으로 10km 이동한다고 생각하면 방향 변화는 약 0.0015°에 불과해요. 지구의 자전과 달의 공전은 잠시 제외하고 이동 효과만 계산한 값이에요.</p>
  <p>우리 눈에는 그 변화가 너무 작아서 달이 거의 같은 방향에 머무는 것처럼 느껴져요. 달이 실제로 나를 따라 움직이는 것은 아니지만, 함께 길을 가는 듯한 그 느낌까지 사라지는 건 아니겠지요.</p>
  <p className="moon-story-sources">더 알아보기 · <Source href="https://svs.gsfc.nasa.gov/5320/">NASA 시차 이야기</Source></p>
 </>},
 {title:'달의 모양이 지구 때문이라는 착각',subtitle:'초승달의 어두운 부분은 지구 그림자일까요?',body:<>
  <Figure name="crescent-moon" width={1280} height={853} alt="푸른 하늘에 가느다란 밝은 면이 드러난 초승달" caption="달은 둥근 채로 있어요. 우리가 보는 밝은 면의 모양이 달라지는 것이지요. 원작 자료의 사진이에요."/>
  <p>초승달을 보면 누군가 둥근 달의 일부를 가려놓은 듯해요. 하지만 평소 달이 차오르고 기우는 것은 지구 그림자 때문이 아니에요. 달은 스스로 빛을 내지 않고 <strong>태양빛을 반사</strong>해요. 보통 달 표면의 절반이 햇빛을 받고 있어요.</p>
  <p>달이 지구 주위를 돌면 태양과 지구, 달이 이루는 각도가 달라져요. 그러면서 햇빛을 받는 반쪽 가운데 지구에서 보이는 부분도 바뀌지요. 밝은 부분을 거의 볼 수 없을 때는 신월, 절반쯤 보일 때는 상현달이나 하현달, 거의 모두 보일 때는 보름달이라고 불러요.</p>
  <p>태양빛이 비치는 부분을 바라보는 각도가 달라진다고 생각하면 이해하기 쉬워요. 달 자체가 얇아졌다 두꺼워지는 것도, 지구가 매일 조금씩 가리는 것도 아니에요. 이런 겉모양의 변화를 <strong>달의 위상</strong>이라고 해요.</p>
  <p>한국에서는 초승달을 해 진 뒤 서쪽 하늘에서, 그믐달을 해 뜨기 전 동쪽 하늘에서 주로 만나요. 그때 달이 태양과 가까운 방향에 있기 때문이에요. 보이는 시간과 높이는 달의 위상뿐 아니라 날짜와 관측 장소에 따라서도 달라집니다.</p>
  <div className="moon-science-note"><h4>달력의 모양이 한 바퀴 도는 시간</h4><p>신월에서 다음 신월까지는 평균 약 29.5일이 걸려요. 달력에서 날짜를 눌러보면 밝은 면이 조금씩 달라지는 흐름을 따라갈 수 있어요. 지구의 그림자가 실제로 달에 드리워지는 월식은 평소의 위상 변화와 다른 현상이에요.</p></div>
  <p className="moon-story-sources">더 알아보기 · <Source href="https://science.nasa.gov/moon/moon-phases/">NASA 달의 위상</Source></p>
 </>},
 {title:'일식이 아주 가끔 일어나는 이유',subtitle:'신월과 보름달은 매달 오는데, 식은 왜 드물까요?',body:<>
  <p>달이 태양 앞을 지나 태양을 가리는 현상이 <strong>일식</strong>이에요. 반대로 지구의 그림자 속으로 달이 들어가는 현상은 <strong>월식</strong>이지요. 일식은 신월 무렵, 월식은 보름달 무렵에 일어날 수 있어요. 하지만 신월과 보름달이라고 해서 매번 식이 생기지는 않아요.</p>
  <p>이유는 달이 도는 길이 살짝 기울어져 있기 때문이에요. 지구가 태양 주위를 도는 평면을 <strong>황도면</strong>이라고 하는데, 달의 공전면은 이 평면에 대해 약 5.1° 기울어져 있어요. 대부분의 신월과 보름달에는 달이 정확한 정렬에서 위나 아래로 비껴가 그림자가 닿지 않아요.</p>
  <Figure name="orbital-tilt" width={602} height={284} alt="지구의 공전면에 대해 기울어진 달의 궤도와 태양, 지구의 관계를 나타내는 설명 그림" caption="달 궤도의 기울기를 보여주는 개념도예요. 천체의 크기와 거리는 실제 비율이 아닙니다. 원작 수록 이미지 · NSO 표시"/>
  <p>달의 궤도가 황도면을 가로지르는 두 지점을 <strong>교점</strong>이라고 불러요. 신월이나 보름달이 이 교점 가까이에서 일어나고, 태양과 지구와 달의 정렬이 맞으면 식이 생길 수 있어요. 달의 공전면과 황도면이 한 평면으로 바뀌는 것은 아니에요.</p>
  <p>일식이 일어나도 모든 곳에서 같은 모습을 볼 수는 없어요. 달 그림자가 지구 표면의 어느 지역을 지나는지에 따라 볼 수 있는 장소와 가려지는 정도가 달라져요. 월식은 그때 달이 떠 있는 밤 지역의 넓은 범위에서 볼 수 있지요.</p>
  <p>그래서 내가 있는 곳에서 만나는 일식은 더욱 특별해요. 하늘의 세 천체가 맞아드는 순간에, 내가 서 있는 자리까지 그 그림자의 길과 만나야 하니까요.</p>
  <p className="moon-story-sources">더 알아보기 · <Source href="https://science.nasa.gov/moon/eclipses/">NASA 일식과 월식</Source> · <Source href="https://science.nasa.gov/eclipses/geometry/">식이 일어나는 조건</Source></p>
 </>},
];

export function MoonStories(){return <section className="moon-stories" id="moon-stories" aria-labelledby="moon-stories-title"><div className="eyebrow">STORIES OF THE MOON</div><h2 id="moon-stories-title">달 이야기</h2><p className="lead">매일 올려다보던 달에, 조금 더 가까이.</p><p className="moon-stories-intro">달이 따라오는 듯했던 밤부터 가느다란 초승달의 비밀까지. 익숙한 장면 속에 숨어 있는 우주 이야기를 만나보세요.</p><div className="moon-story-list">{stories.map((story,index)=><details className="moon-story" key={story.title} open={index===0}><summary><span className="moon-story-number">0{index+1}</span><span><h3>{story.title}</h3><span className="moon-story-subtitle">{story.subtitle}</span></span><ChevronDown size={18} aria-hidden="true"/></summary><div className="moon-story-body">{story.body}</div></details>)}</div></section>}
