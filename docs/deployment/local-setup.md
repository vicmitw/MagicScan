# 🚀 Deployment Automático: PC Desarrollo → Mini PC

> **Objetivo:** Hacer deploy del backend, base de datos y cambios sin tocar físicamente el mini PC.

## 🏗️ **Arquitectura de Deployment**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PC Desarrollo │    │     GitHub      │    │     Mini PC     │
│                 │    │                 │    │                 │
│  • Código       │───▶│  • Repository   │───▶│  • Production   │
│  • Tests        │    │  • Actions      │    │  • Database     │
│  • Scripts      │    │  • Webhooks     │    │  • API          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 **Setup Inicial del Mini PC**

### **1. Configuración SSH**
```bash
# En el mini PC
sudo apt update
sudo apt install openssh-server

# Configurar clave SSH
ssh-keygen -t ed25519 -C "magicscan-minipc"

# En tu PC de desarrollo
ssh-copy-id usuario@IP_MINI_PC

# Crear usuario para deployment
sudo adduser magicscan-deploy
sudo usermod -aG sudo magicscan-deploy
sudo usermod -aG docker magicscan-deploy
```

### **2. Estructura de Directorios en Mini PC**
```bash
/home/magicscan-deploy/
├── 🚀 apps/
│   ├── current/              # Versión actual en producción
│   ├── releases/             # Historial de releases
│   └── shared/               # Archivos compartidos
│       ├── database/         # Base de datos persistente
│       ├── uploads/          # Archivos subidos
│       ├── logs/            # Logs de aplicación
│       └── env/             # Variables de entorno
├── 🛠️ scripts/              # Scripts de deployment
└── 📊 monitoring/           # Logs y monitoreo
```

## 📜 **Scripts de Deployment**

### **Deployment Script Principal**
```bash
#!/bin/bash
# deploy.sh - Script principal de deployment

set -e  # Salir en error

# Configuración
MINI_PC_IP="192.168.1.100"  # Cambiar por IP real
MINI_PC_USER="magicscan-deploy"
PROJECT_DIR="/home/magicscan-deploy/apps"
RELEASE_DIR="$PROJECT_DIR/releases/$(date +%Y%m%d_%H%M%S)"

echo "🚀 Iniciando deployment a Mini PC..."

# 1. Crear directorio de release
ssh $MINI_PC_USER@$MINI_PC_IP "mkdir -p $RELEASE_DIR"

# 2. Subir código
echo "📦 Subiendo código..."
rsync -avz --exclude='.git' \
           --exclude='node_modules' \
           --exclude='__pycache__' \
           --exclude='.env' \
           ./backend/ $MINI_PC_USER@$MINI_PC_IP:$RELEASE_DIR/

# 3. Subir configuración
scp ./deployment/mini-pc/.env $MINI_PC_USER@$MINI_PC_IP:$RELEASE_DIR/

# 4. Ejecutar deployment remoto
ssh $MINI_PC_USER@$MINI_PC_IP "bash $RELEASE_DIR/deploy_remote.sh"

echo "✅ Deployment completado!"
```

### **Script Remoto en Mini PC**
```bash
#!/bin/bash
# deploy_remote.sh - Ejecutado en el mini PC

set -e

PROJECT_DIR="/home/magicscan-deploy/apps"
CURRENT_DIR="$PROJECT_DIR/current"
RELEASE_DIR="$PROJECT_DIR/releases/$(basename $PWD)"

echo "🔧 Configurando entorno..."

# 1. Instalar dependencias
python3 -m pip install -r requirements.txt

# 2. Ejecutar migraciones de base de datos
export PYTHONPATH=$PWD
python3 database/migrations/run_migrations.py

# 3. Compilar assets si hay cambios en web
if [ -d "web/" ]; then
    cd web/
    npm install
    npm run build
    cd ..
fi

# 4. Detener servicios
sudo systemctl stop magicscan-api
sudo systemctl stop magicscan-web

# 5. Actualizar symlink
rm -rf $CURRENT_DIR
ln -sf $RELEASE_DIR $CURRENT_DIR

# 6. Reiniciar servicios
sudo systemctl start magicscan-api
sudo systemctl start magicscan-web

# 7. Verificar health check
sleep 5
curl -f http://localhost:8000/health || exit 1

echo "✅ Deployment remoto completado!"

# 8. Limpiar releases viejos (mantener últimos 5)
cd $PROJECT_DIR/releases
ls -t | tail -n +6 | xargs rm -rf
```

## 🗄️ **Deployment de Base de Datos**

### **Script de Migraciones**
```python
#!/usr/bin/env python3
# database/migrations/run_migrations.py

import os
import sys
import psycopg2
from pathlib import Path

def run_migrations():
    """Ejecuta migraciones de base de datos"""
    
    # Configuración de base de datos
    DB_CONFIG = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'database': os.getenv('DB_NAME', 'magicscan'),
        'user': os.getenv('DB_USER', 'magicscan'),
        'password': os.getenv('DB_PASSWORD'),
    }
    
    # Conectar a base de datos
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Crear tabla de migraciones si no existe
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS schema_migrations (
            version VARCHAR(255) PRIMARY KEY,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Obtener migraciones aplicadas
    cursor.execute("SELECT version FROM schema_migrations")
    applied = {row[0] for row in cursor.fetchall()}
    
    # Ejecutar migraciones pendientes
    migrations_dir = Path(__file__).parent / "sql"
    for migration_file in sorted(migrations_dir.glob("*.sql")):
        version = migration_file.stem
        
        if version not in applied:
            print(f"🔄 Aplicando migración: {version}")
            
            with open(migration_file, 'r') as f:
                sql = f.read()
            
            try:
                cursor.execute(sql)
                cursor.execute(
                    "INSERT INTO schema_migrations (version) VALUES (%s)",
                    (version,)
                )
                conn.commit()
                print(f"✅ Migración {version} aplicada")
                
            except Exception as e:
                print(f"❌ Error en migración {version}: {e}")
                conn.rollback()
                sys.exit(1)
    
    cursor.close()
    conn.close()
    print("🎉 Todas las migraciones aplicadas!")

if __name__ == "__main__":
    run_migrations()
```

### **Migraciones SQL**
```sql
-- database/migrations/sql/001_initial_schema.sql

-- Usuarios
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    settings JSONB DEFAULT '{}'
);

-- Cartas MTG (base de datos completa)
CREATE TABLE IF NOT EXISTS mtg_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scryfall_id UUID UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    set_code VARCHAR(10) NOT NULL,
    collector_number VARCHAR(10) NOT NULL,
    image_uris JSONB,
    prices JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Colecciones de usuarios
CREATE TABLE IF NOT EXISTS user_collections (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    card_id UUID REFERENCES mtg_cards(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    condition VARCHAR(20) DEFAULT 'near_mint',
    foil BOOLEAN DEFAULT FALSE,
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_collections_user_id ON user_collections(user_id);
CREATE INDEX IF NOT EXISTS idx_user_collections_card_id ON user_collections(card_id);
CREATE INDEX IF NOT EXISTS idx_mtg_cards_name ON mtg_cards(name);
CREATE INDEX IF NOT EXISTS idx_mtg_cards_set_code ON mtg_cards(set_code);
```

## 🚀 **Comandos de Desarrollo**

### **Deployment Rápido**
```bash
# Deployment completo
make deploy

# Solo backend
make deploy-backend

# Solo base de datos
make deploy-db

# Rollback a versión anterior
make rollback
```

### **Makefile de Desarrollo**
```makefile
# Makefile para comandos de deployment

.PHONY: deploy deploy-backend deploy-db rollback logs

# Variables
MINI_PC_IP=192.168.1.100
MINI_PC_USER=magicscan-deploy

deploy:
	@echo "🚀 Deploying to Mini PC..."
	@./scripts/deploy.sh

deploy-backend:
	@echo "⚡ Deploying backend only..."
	@./scripts/deploy_backend_only.sh

deploy-db:
	@echo "🗄️ Running database migrations..."
	@ssh $(MINI_PC_USER)@$(MINI_PC_IP) "cd apps/current && python3 database/migrations/run_migrations.py"

rollback:
	@echo "🔄 Rolling back to previous version..."
	@./scripts/rollback.sh

logs:
	@echo "📊 Showing application logs..."
	@ssh $(MINI_PC_USER)@$(MINI_PC_IP) "tail -f apps/shared/logs/app.log"

health:
	@echo "🏥 Checking application health..."
	@curl -f http://$(MINI_PC_IP):8000/health && echo "✅ API is healthy"

ssh:
	@ssh $(MINI_PC_USER)@$(MINI_PC_IP)
```

## 🔄 **GitHub Actions (Deployment Automático)**

```yaml
# .github/workflows/deploy.yml

name: Deploy to Mini PC

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup SSH
      uses: webfactory/ssh-agent@v0.5.4
      with:
        ssh-private-key: ${{ secrets.MINI_PC_SSH_KEY }}
    
    - name: Add Mini PC to known hosts
      run: |
        ssh-keyscan -H ${{ secrets.MINI_PC_IP }} >> ~/.ssh/known_hosts
    
    - name: Deploy to Mini PC
      run: |
        ./scripts/deploy.sh
      env:
        MINI_PC_IP: ${{ secrets.MINI_PC_IP }}
        MINI_PC_USER: ${{ secrets.MINI_PC_USER }}
    
    - name: Health Check
      run: |
        sleep 10
        curl -f http://${{ secrets.MINI_PC_IP }}:8000/health
```

## 📊 **Monitoreo Post-Deployment**

### **Health Check Endpoint**
```python
# backend/routers/health.py

from fastapi import APIRouter
from sqlalchemy.orm import Session
from core.database import get_db

router = APIRouter()

@router.get("/health")
async def health_check(db: Session = Depends(get_db)):
    """Health check endpoint para verificar que todo funciona"""
    
    try:
        # Verificar base de datos
        db.execute("SELECT 1")
        
        # Verificar servicios críticos
        health_status = {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat(),
            "version": "1.0.0"
        }
        
        return health_status
        
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Service unhealthy: {str(e)}"
        )
```

## 🛠️ **Comandos de Uso Diario**

```bash
# Desarrollo normal
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main
# 👆 Esto automáticamente hace deploy via GitHub Actions

# Deployment manual inmediato
make deploy

# Ver logs en tiempo real
make logs

# Verificar que todo funciona
make health

# Entrar al mini PC si necesitas debugging
make ssh

# Rollback si algo sale mal
make rollback
```

¿Te parece bien este setup? Es completamente automatizado y te permite desarrollar sin tocar nunca físicamente el mini PC. ¿Quieres que detalle alguna parte específica o prefieres que sigamos con otro componente? 