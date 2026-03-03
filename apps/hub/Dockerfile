FROM node:20-alpine AS deps
WORKDIR /app
COPY apps/hub/package*.json ./apps/hub/
COPY packages/ui/package.json ./packages/ui/
COPY packages/ui/src ./packages/ui/src
COPY packages/tailwind-config/package.json ./packages/tailwind-config/
COPY packages/tailwind-config/index.ts ./packages/tailwind-config/
COPY packages/tailwind-config/tailwind.preset.ts ./packages/tailwind-config/
COPY apps/hub/prisma ./apps/hub/prisma
WORKDIR /app/apps/hub
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
RUN npx prisma generate --schema=prisma/schema.prisma

FROM node:20-alpine AS builder
WORKDIR /app
COPY apps/hub/package*.json ./apps/hub/
COPY --from=deps /app/apps/hub/node_modules ./apps/hub/node_modules
COPY apps/hub ./apps/hub
COPY packages/ui ./packages/ui
COPY packages/tailwind-config ./packages/tailwind-config
WORKDIR /app/apps/hub
RUN npm run build && npm prune --omit=dev
RUN npx prisma generate --schema=prisma/schema.prisma

FROM node:20-alpine AS runner
WORKDIR /app/apps/hub
COPY --from=builder /app/apps/hub/.next ./.next
COPY --from=builder /app/apps/hub/public ./public
COPY --from=builder /app/apps/hub/package.json ./package.json
COPY --from=builder /app/apps/hub/node_modules ./node_modules
ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "run", "start"]
