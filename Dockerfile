FROM node:12

LABEL maintainer="Luis Luyo Hernández (luis.luyohernandez@gmail.com)"

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# TypeScript
RUN npm run build

CMD ["npm","start"]
