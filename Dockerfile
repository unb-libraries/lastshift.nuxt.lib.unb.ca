FROM node:26-alpine AS base

ENV APP_ROOT=/nuxt

ENV NODE_ENV=production

ENV NUXT_SITE_ID=lastshift
ENV NUXT_SITE_URI=lastshift.lib.unb.ca
ENV NUXT_SITE_UUID=1884a385-9812-4470-bbf8-40fd42e6745f
ENV NUXT_PORT=80
ENV NITRO_PORT=80
ENV HUSKY=0

WORKDIR $APP_ROOT

COPY . .

RUN apk update && \
    apk add bash && \
    npm install -g corepack && \
    corepack enable pnpm

FROM base AS development

ENV NODE_ENV=development

RUN apk update && \
    apk add curl && \
    pnpm install

CMD ["pnpm", "dev"]

FROM base AS build

COPY . .

RUN pnpm install --frozen-lockfile --prod=false && \
    pnpm run generate


FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /nuxt/.output/public /usr/share/nginx/html

EXPOSE 80
