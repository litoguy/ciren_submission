FROM node:18-alpine
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev || npm install --omit=dev
COPY src ./src
RUN mkdir -p data
VOLUME ["/usr/src/app/data"]
EXPOSE 3000
CMD ["node", "src/app.js"]
