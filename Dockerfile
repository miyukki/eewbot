FROM node:6.10-alpine

COPY package.json /src/package.json
RUN cd /src; npm install --production

COPY . /src

WORKDIR /src
CMD npm run start --silent
