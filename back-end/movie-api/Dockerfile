# Dockerfile
# Resmi Node.js imajını kullan
FROM node:18-alpine
# Çalışma dizinini ayarla
WORKDIR /usr/src/app
# package.json ve package-lock.json'ı kopyala
COPY package*.json ./
# Bağımlılıkları yükle
RUN npm install
# Geriye kalan uygulama kodunu kopyala
COPY . .
# Uygulamanın çalışacağı portu bildir
EXPOSE 4000
# Uygulamayı başlatma komutu
CMD ["node", "index.js"]