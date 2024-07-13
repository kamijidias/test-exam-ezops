# Use a imagem oficial do Node.js como base
FROM node:14

# Defina o diretório de trabalho no contêiner
WORKDIR /usr/src/app

# Copie o package.json e o package-lock.json
COPY package*.json ./

# Instalando as dependências
RUN npm install

# Copiando o restante do código da aplicação
COPY . .

# porta em que o app irá rodar
EXPOSE 3000

# Comando para rodar a aplicação
CMD ["node", "server/server.js"]