FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* ./
RUN \
  if [ -f package-lock.json ]; then npm ci; \
  elif [ -f package.json ]; then npm i; \
  else echo "Package not found." && exit 1; \
  fi

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# ENV ADMIN_PATH=admin
# ENV STRAPI_ADMIN_BACKEND_URL=https://localhost

# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV STRAPI_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 1337

ENV PORT=1337

CMD ["npm", "run", "develop"]