FROM mcr.microsoft.com/playwright:v1.57.0-noble

RUN npm install -g netlify-cli serve
RUN apt update && install -y jq