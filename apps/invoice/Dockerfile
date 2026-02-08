FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install --production

FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app ./
ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "run", "start"]
