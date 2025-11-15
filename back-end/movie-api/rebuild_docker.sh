#!/bin/bash
echo "Container'ları durduruyor..."
sudo docker compose down

echo "Image'ı yeniden build ediyor..."
sudo docker compose build --no-cache backend

echo "Container'ları başlatıyor..."
sudo docker compose up -d

echo "Backend loglarını gösteriyor..."
sleep 3
sudo docker compose logs backend | tail -30
