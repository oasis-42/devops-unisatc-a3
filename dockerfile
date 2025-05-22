# Usa a imagem oficial do Node.js
FROM node:18

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos de dependência
COPY package*.json ./

# Instala as dependências
RUN npm install

# Copia o restante da aplicação
COPY . .

# Expõe a porta padrão do Strapi
EXPOSE 1337

# Comando para iniciar o Strapi em modo produção
CMD ["npm", "run", "develop"]
