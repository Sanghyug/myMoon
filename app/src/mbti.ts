// Editorial analogies to the written stories, never a birth-based MBTI assessment.
const profiles = {
 INFP:{theme:'가치와 상상',description:'자신에게 소중한 의미를 찾고, 마음속 생각과 가능성을 천천히 키우는 이야기라는 점에서 연결했어요.'},
 INFJ:{theme:'맥락과 공감',description:'경험과 관계의 맥락을 깊이 살피고, 서로를 이해할 방법을 찾는 이야기라는 점에서 연결했어요.'},
 ISFP:{theme:'취향과 표현',description:'자신만의 취향과 감정을 존중하고, 작은 경험과 표현을 소중히 하는 이야기라는 점에서 연결했어요.'},
 ISFJ:{theme:'세심한 배려',description:'작은 변화와 약속을 기억하고, 조용한 행동으로 마음을 전하는 이야기라는 점에서 연결했어요.'},
 ISTJ:{theme:'준비와 꾸준함',description:'필요한 것을 꼼꼼히 챙기고, 순서와 경험을 바탕으로 차근차근 이어가는 이야기라는 점에서 연결했어요.'},
 INTJ:{theme:'방향과 계획',description:'중요한 기준과 전체 방향을 살피고, 목표를 위해 생각을 정리하는 이야기라는 점에서 연결했어요.'},
 INTP:{theme:'질문과 탐구',description:'여러 이유와 가능성을 비교하고, 궁금한 것을 깊이 이해하려는 이야기라는 점에서 연결했어요.'},
 ENFP:{theme:'가능성과 나눔',description:'새로운 가능성에 호기심을 느끼고, 떠오른 생각과 기대를 다른 사람과 나누는 이야기라는 점에서 연결했어요.'},
 ENFJ:{theme:'응원과 연결',description:'사람들의 생각과 장점을 이어주고, 함께할 방향을 찾는 이야기라는 점에서 연결했어요.'},
 ESFJ:{theme:'함께하는 배려',description:'주변 사람의 필요를 살피고, 구체적인 도움으로 함께하는 자리를 챙기는 이야기라는 점에서 연결했어요.'},
};
export type StoryMbti = keyof typeof profiles;
// Rows follow the 30 story groups; columns follow their five existing variants.
const storyTypes: readonly (readonly StoryMbti[])[] = [
 ['INFP','ISFJ','INFP','INFP','ISFP'],
 ['ENFP','ISFJ','ISTJ','INFJ','ISFJ'],
 ['ISFP','ISFP','INFP','INTJ','INTP'],
 ['INFP','ENFJ','INTJ','INTJ','ISTJ'],
 ['ENFJ','ISTJ','INTJ','INFP','ISTJ'],
 ['ISFP','ESFJ','INTP','INTP','INTJ'],
 ['INTP','ENFP','INFP','INFP','ISFJ'],
 ['ENFJ','ENFJ','INTJ','INTP','ISTJ'],
 ['ISFP','ENFJ','ISTJ','INTP','ISFP'],
 ['INFJ','ENFJ','INFP','ISTJ','ISFJ'],
 ['ISFP','ENFP','INTJ','INFP','INFP'],
 ['ENFP','ENFJ','INFP','INFJ','ISFJ'],
 ['ENFJ','ENFP','ISFJ','INFP','ISFJ'],
 ['ENFP','INFP','INFP','ISFP','INFP'],
 ['ENFJ','INFJ','ISTJ','INTP','INFP'],
 ['ENFP','ENFJ','ESFJ','ISFJ','ISTJ'],
 ['ENFJ','INFJ','ISTJ','INFJ','INTJ'],
 ['INFP','ISFJ','ISFP','INFJ','INFJ'],
 ['ISTJ','INFJ','ISTJ','INTP','ISTJ'],
 ['ISTJ','INFP','ISFP','ISFP','INFP'],
 ['ISFJ','ISFP','INFP','INFP','ISFP'],
 ['ISFJ','ISFJ','INTJ','INFP','INFP'],
 ['ISFJ','ISFJ','INTJ','INFJ','INTP'],
 ['ISTJ','INFJ','INFP','ISTJ','ISFP'],
 ['INFP','ISFP','INFJ','INTP','INFP'],
 ['INFP','INFP','ISTJ','INTP','ISFP'],
 ['INFP','ENFP','INTJ','INTP','INTJ'],
 ['INFP','ISTJ','INFP','INTJ','INFJ'],
 ['INFP','ISTJ','INTJ','ISFP','ISFP'],
 ['ISFJ','INTP','ISTJ','INFP','INFJ'],
];
export function storyMbti(message:{age:number;distance:number;message:string}) {
 const type=storyTypes[message.age]?.[message.distance];
 if(!type)throw new Error('이 성향 이야기의 MBTI 비유를 찾을 수 없어요.');
 return {type,...profiles[type],excerpt:message.message.split('\n\n')[0]};
}
