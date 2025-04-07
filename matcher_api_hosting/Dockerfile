FROM node:20.18.1-bookworm

WORKDIR /app
COPY . .

RUN npm install

ENTRYPOINT [ "node", "server.js" ]