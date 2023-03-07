FROM nginx:latest
COPY /nginx/conf/default.conf /etc/nginx/conf.d/
COPY nginx/html /usr/share/nginx/html
