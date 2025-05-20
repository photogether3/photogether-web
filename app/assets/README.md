# Photogether 프로젝트의 프론트엔드 자산 관리 가이드

## Vite + Rails 작업 환경

이 프로젝트는 기존 Rails 에셋 파이프라인(Sprockets) 대신 **Vite**를 사용하여 프론트엔드 자산(JavaScript, CSS 등)을 관리합니다.

### 주요 특징

- **Vite**: 빠른 개발 서버와 최적화된 빌드를 제공하는 최신 프론트엔드 툴
- **Tailwind CSS**: 유틸리티 클래스 기반의 CSS 프레임워크
- **ESM 모듈 시스템**: 현대적인 JavaScript 모듈 시스템 사용

### 개발 환경

개발 중에는 Vite 개발 서버가 메모리 내에서 자산을 제공하며, 빠른 HMR(Hot Module Replacement)을 지원합니다:

```
bin/dev
```

이 명령어는 Rails 서버와 Vite 개발 서버를 동시에 실행합니다.

### 빌드 작업

프로덕션 환경을 위한 빌드는 다음 명령어로 수행합니다:

```
npm run build
```

### 빌드 결과물

- 개발 환경: Vite 서버가 메모리에서 자산 제공
- 배포 환경: 빌드된 최종 결과물이 `app/assets/builds` 디렉토리에 생성됨

### 주요 설정 파일

- `vite.config.js`: Vite 설정
- `Procfile.dev`: 개발 서버 실행 설정
- `package.json`: 프론트엔드 의존성 및 스크립트