### run the code
FROM nginx:alpine AS runner
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]