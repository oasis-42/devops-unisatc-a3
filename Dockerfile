FROM node:22.16.0-alpine3.21

WORKDIR /app

COPY package*.json ./

RUN npm install -g pnpm@latest-10 && \
    pnpm install

COPY . .

EXPOSE 1337

CMD ["pnpm", "run", "develop"]
