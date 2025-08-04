# Multi-stage build for NestJS backend
FROM node:20-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# package.json과 package-lock.json 복사하여 의존성 설치
COPY package*.json ./
RUN npm ci

# 소스 코드 복사
COPY . .

# TypeScript 빌드 실행
RUN npm run build

# Production stage
FROM node:20-alpine AS production

# 작업 디렉토리 설정
WORKDIR /app

# package.json과 package-lock.json 복사
COPY package*.json ./

# 프로덕션 의존성만 설치
RUN npm ci --only=production && npm cache clean --force

# 빌드된 파일 복사
COPY --from=builder /app/dist ./dist

# 포트 3000 노출 (NestJS 기본 포트)
EXPOSE 3000

# non-root 사용자로 실행
USER node

# 애플리케이션 시작
CMD ["npm", "run", "start:prod"]