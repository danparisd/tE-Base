FROM node:8-stretch-slim as builder
RUN apt-get update && apt-get install -y git && git clone https://github.com/wycliffeassociates/translationExchange /translationExchange && git clone https://github.com/wycliffeassociates/tE-backend /tE-backend
WORKDIR /translationExchange
RUN npm link cross-env && npm install --production && npm run build

FROM python:3.6-slim-stretch
ENV PYTHONUNBUFFERED 1
ENV NODE_ENV production 
RUN echo "deb http://httpredir.debian.org/debian jessie-backports main non-free\n" >> /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian jessie-backports main non-free\n" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y ffmpeg
COPY . /
COPY --from=builder /tE-backend /te-temp
COPY --from=builder /translationExchange /te-temp/tRecorderApi/frontend
RUN pip install -r /config/requirements.txt
VOLUME [ "/var/www/html/tE-backend" ]
WORKDIR /var/www/html/tE-backend/tRecorderApi