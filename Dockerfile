FROM node:20.11.0-alpine as base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app

FROM base as builder

COPY . .

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm --frozen-lockfile --ignore-scripts install

RUN pnpm build

FROM base as runner

COPY --from=builder /app /app

WORKDIR /app

RUN corepack enable

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm --prod --ignore-scripts --frozen-lockfile install

RUN apk add --no-cache bash tzdata git make clang

ENV NODE_ENV=production

EXPOSE 3000

RUN chown -R node /app

USER node 

CMD ["pnpm", "start"]
