from node:lts-alpine as builder
add . /opt/app/
workdir /opt/app
run npm install && npm install --save jquery && npm run build

from nginx:stable-alpine
copy nginx/default.conf /etc/nginx/conf.d/default.conf
copy --from=builder /opt/app/dist/quiz-frontend /usr/share/nginx/html
