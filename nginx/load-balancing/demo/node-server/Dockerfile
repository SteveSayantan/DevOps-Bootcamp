FROM node:slim

WORKDIR /app/

COPY package.json .

RUN npm i

COPY . .

ENTRYPOINT [ "npm" ]

CMD [ "start" ]