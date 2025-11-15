# Veritabanı Kurulum Talimatları

## Yöntem 1: Docker ile (Önerilen)

1. Docker container'ları başlatın:
```bash
cd back-end/movie-api
docker-compose up -d
```

2. Veritabanı başlatma script'i otomatik olarak çalışacak. Logları görmek için:
```bash
docker-compose logs backend
```

## Yöntem 2: Local olarak çalıştırmak

1. Önce PostgreSQL'in çalıştığından emin olun (Docker ile):
```bash
docker-compose up -d db
```

2. `.env` dosyası oluşturun (`back-end/movie-api/.env`):
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=movie_user
DB_PASSWORD=12345
DB_NAME=ok_or_notokdb
JWT_SECRET=supersecretkey123456789
TMDB_API_KEY=
```

3. Veritabanını başlatın:
```bash
npm run init-db
```

4. Backend'i başlatın:
```bash
npm start
```

## Test Kullanıcıları

Veritabanı başlatıldıktan sonra şu kullanıcılar oluşturulur:

1. **Email:** test1@example.com  
   **Şifre:** password123

2. **Email:** test2@example.com  
   **Şifre:** password123

3. **Email:** admin@example.com  
   **Şifre:** admin123

## Sorun Giderme

### "password authentication failed" hatası alıyorsanız:

1. PostgreSQL container'ının çalıştığından emin olun:
```bash
docker-compose ps
```

2. `.env` dosyasındaki bilgilerin `docker-compose.yml` ile eşleştiğinden emin olun.

3. Container'ı yeniden başlatın:
```bash
docker-compose down
docker-compose up -d
```

