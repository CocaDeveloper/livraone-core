FROM node:20-alpine AS deps
WORKDIR /app
COPY apps/marketing/package*.json ./apps/marketing/
COPY packages/ui/package.json ./packages/ui/
COPY packages/ui/src ./packages/ui/src
WORKDIR /app/apps/marketing
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
RUN mkdir -p /app/apps/marketing/node_modules/@livraone \
  && rm -rf /app/apps/marketing/node_modules/@livraone/ui \
  && cp -R /app/packages/ui /app/apps/marketing/node_modules/@livraone/ui

FROM node:20-alpine AS builder
WORKDIR /app
COPY apps/marketing/package*.json ./apps/marketing/
COPY --from=deps /app/apps/marketing/node_modules ./apps/marketing/node_modules
COPY apps/marketing ./apps/marketing
COPY packages/ui ./packages/ui
WORKDIR /app/apps/marketing
RUN npm run build && npm prune --omit=dev

FROM node:20-alpine AS runner
WORKDIR /app/apps/marketing
COPY --from=builder /app/apps/marketing/.next ./.next
COPY --from=builder /app/apps/marketing/public ./public
COPY --from=builder /app/apps/marketing/package.json ./package.json
COPY --from=builder /app/apps/marketing/node_modules ./node_modules
ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "run", "start"]
