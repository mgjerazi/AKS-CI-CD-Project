FROM node:latest AS build
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:latest AS prod-stage
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /usr/src/app/dist/quiz-frontend /usr/share/nginx/html
EXPOSE 80
#CMD ["nginx","-g","deamon off;"]


#BEST PRACTICE
#from node:lts-alpine as builder
#add . /opt/app/
#workdir /opt/app
#run npm install && npm install --save jquery && npm run build
#
#from nginx:stable-alpine
#copy nginx/default.conf /etc/nginx/conf.d/default.conf
#copy --from=builder /opt/app/dist/quiz-frontend /usr/share/nginx/html
