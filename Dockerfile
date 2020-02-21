FROM nginx:latest
EXPOSE 80/tcp
ADD content /usr/share/nginx/html
