#!/bin/bash

# Прерывать выполнение скрипта при возникновении любой ошибки
set -e

# --- НАСТРОЙКИ РЕПОЗИТОРИЯ (Замените на свои актуальные данные) ---
REPO_URL="https://github.com/ilyapatis/docker-python.git"
PROJECT_DIR="docker"
TARGET_PATH="/opt/$PROJECT_DIR"

echo "=== 1. Подготовка директории в /opt ==="
# Создаем директорию /opt, если она отсутствует
sudo mkdir -p /opt
if [ -d "$TARGET_PATH" ]; then
    echo "Обнаружена существующая копия проекта. Выполняем обновление через git pull..."
    cd "$TARGET_PATH"
    sudo git pull
else
    echo "Папка проекта не найдена. Клонируем репозиторий..."
    cd /opt
    sudo git clone "$REPO_URL" "$PROJECT_DIR"
    cd "$TARGET_PATH"
fi

echo "=== 2. Очистка старых конфликтующих Docker-ресурсов ==="
# На случай, если в системе остались зависшие тома от прошлых запусков этого проекта
sudo docker compose down -v --remove-orphans || true

echo "=== 3. Запуск всего проекта в Docker Compose ==="
# Принудительно собираем образы (включая Dockerfile.python) и запускаем контейнеры в фоне
sudo docker compose up -d --build

echo "=== 4. Проверка статуса запущенных контейнеров ==="
sudo docker compose ps

echo "========================================================"
echo " Скрипт успешно выполнен! Проект развернут в $TARGET_PATH"
echo " Для просмотра логов используйте команду:"
echo " cd $TARGET_PATH && sudo docker compose logs -f"
echo "========================================================"