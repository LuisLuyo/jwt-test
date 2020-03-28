FROM node:12

MAINTAINER Luis Luyo Hernández (luis.luyohernandez@gmail.com)

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# TypeScript
CMD ["npm","build"]

CMD ["npm","start"]
