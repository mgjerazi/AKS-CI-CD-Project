FROM node:lts-alpine as builder
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm install
RUN npm install jquery
COPY . .
RUN npm run build
# Stage2
FROM nginx:latest AS prod
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /usr/src/app/dist/quiz-frontend /usr/share/nginx/html
EXPOSE 80:80



########################################################################################################################
#FROM node:latest AS build
#WORKDIR /usr/src/app
#COPY package.json package-lock.json ./
#RUN npm install
#COPY . .
#RUN npm run build
#
#FROM nginx:latest AS prod-stage
#COPY ./nginx.conf /etc/nginx/conf.d/default.conf
#COPY --from=build /usr/src/app/dist/quiz-frontend /usr/share/nginx/html
#EXPOSE 80
#CMD ["nginx","-g","deamon off;"]
########################################################################################################################
#Best Practice
#from node:lts-alpine as builder
#add . /opt/app/
#workdir /opt/app
#run npm install && npm install --save jquery && npm run build
#
#from nginx:stable-alpine
#copy ./nginx.conf /etc/nginx/conf.d/default.conf
#copy --from=builder /opt/app/dist/quiz-frontend /usr/share/nginx/html
########################################################################################################################
#STEPS
#ng build --prod
#docker build -t frontquizaks .
#docker run -p 62:80 -d --name frontendquizaks frontendquizaks
#docker login
#docker images
#docker tag frontquizaks:latest mariolgjerazi/frontquizaks
#docker push mariolgjerazi/frontquizaks
#kubectl get deploy,svc,ing



