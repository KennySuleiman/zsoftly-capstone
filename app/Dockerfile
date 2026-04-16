FROM nginx:latest

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY page1.html /usr/share/nginx/html/
COPY page2.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
