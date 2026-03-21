FROM nginx:alpine
# Change the default Nginx port from 80 to 8080
RUN sed -i 's/80/8080/g' /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]FROM nginx:alpine
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

