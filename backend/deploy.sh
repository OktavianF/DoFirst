#!/bin/bash

# Configuration
USER="nadhia"
HOST="52.172.248.68"
KEY_PATH="nadhia-key.pem"
REMOTE_PATH="~/backend"
PROCESS_NAME="dofirst-backend"

echo "🚀 Memulai proses deployment..."

# 1. Local Build Check
echo "🔍 Menjalankan build lokal untuk mengecek error..."
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Build lokal gagal! Perbaiki error TypeScript sebelum deploy."
    exit 1
fi

# 2. Archive Production Files
echo "📦 Mengompres data (tanpa node_modules)..."
tar -czf deploy.tar.gz --exclude='node_modules' --exclude='.git' --exclude='deploy.sh' .
if [ $? -ne 0 ]; then
    echo "❌ Gagal mengompres data!"
    exit 1
fi

# 3. Transfer Archive to VM
echo "✈️  Mengirim data ke VM Azure ($HOST)..."
scp -i "$KEY_PATH" deploy.tar.gz "$USER@$HOST:~/backend-deploy.tar.gz"
if [ $? -ne 0 ]; then
    echo "❌ Transfer file gagal! Cek koneksi internet atau SSH key."
    rm deploy.tar.gz
    exit 1
fi

# 4. Remote Script Execution
echo "🧱 Menjalankan setup di server..."
ssh -i "$KEY_PATH" "$USER@$HOST" << EOF
    # Folder setup
    mkdir -p "$REMOTE_PATH"
    tar -xzf ~/backend-deploy.tar.gz -C "$REMOTE_PATH"
    
    # Dependensi & Database
    cd "$REMOTE_PATH"
    echo "📦 Menginstal dependensi di server..."
    npm install --omit=dev
    npm install typescript tsx # Ensure build tools are present if needed, though node_modules should be clean
    
    echo "💎 Menjalankan Prisma Generate..."
    npx prisma generate
    
    # Build on Server
    echo "🏗️  Membuat build di server..."
    npm run build
    
    # PM2 Restart
    echo "🔄 Me-restart PM2 ($PROCESS_NAME)..."
    pm2 restart "$PROCESS_NAME" || pm2 start "npm run start:prod" --name "$PROCESS_NAME"
    
    # Cleanup on server
    rm ~/backend-deploy.tar.gz
EOF

if [ $? -ne 0 ]; then
    echo "❌ Gagal melakukan setup di server!"
    rm deploy.tar.gz
    exit 1
fi

# 5. Local Cleanup & Verification
echo "🧹 Membersihkan file lokal sementara..."
rm deploy.tar.gz

echo "✅ Deployment Sukses!"
echo "📋 Hasil Health Check:"
curl -s "http://$HOST:3000/api/health" | grep "ok" && echo "  - Status: CONNECTED" || echo "  - Status: PENDING (Cek port 3000 di Azure)"
