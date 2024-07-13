# Usando a imagem oficial do Node.js como base para construção
FROM node:14 AS build-stage

# Definindo o diretório de trabalho no contêiner
WORKDIR /app

# Copiando o package.json e o package-lock.json
COPY package*.json ./

# Instalando as dependências
RUN npm install

# Copiando o restante do código da aplicação
COPY . .

# Compileando a aplicação para produção
RUN npm run build

# Usando uma imagem leve do Nginx para servir os arquivos estáticos
FROM nginx:alpine AS production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Expondo a porta em que o app irá rodar
EXPOSE 80

# Comando para iniciar o Nginx
CMD ["nginx", "-g", "daemon off;"]