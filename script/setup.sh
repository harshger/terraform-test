#!/bin/bash

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/log/setup_script.log 2>&1

echo "Starting setup script"

echo "Installing Node.js and npm"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get update
apt-get install -y nodejs

echo "Creating application directory"
mkdir -p /app
cd /app

echo "Creating application files"
cat > /app/app.js << 'EOL'
const express = require('express');
const sql = require('mssql');
const app = express();

const config = {
    user: "${db_user}",
    password: "${db_password}",
    server: "${db_server}",
    database: "${db_name}",
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};

app.get('/', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT GETDATE() as serverTime`;
        res.json({
            message: 'Application is running successfully!',
            serverTime: result.recordset[0].serverTime,
            hostname: require('os').hostname()
        });
    } catch (err) {
        res.status(500).json({
            message: 'Error connecting to database',
            error: err.message,
            hostname: require('os').hostname()
        });
    }
});

app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.listen(${port}, () => {
    console.log(`App listening at http://localhost:${port}`);
});
EOL

cat > /app/package.json << 'EOL'
{
  "name": "test-app",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.17.1",
    "mssql": "^9.1.1"
  }
}
EOL

echo "Installing npm dependencies..."
cd /app
npm install

echo "Creating systemd service"
cat > /etc/systemd/system/webapp.service << 'EOL'
[Unit]
Description=Web App
After=network.target

[Service]
WorkingDirectory=/app
ExecStart=/usr/bin/node /app/app.js
Restart=always
User=root
Environment=PORT=80

[Install]
WantedBy=multi-user.target
EOL

echo "Starting webapp service"
systemctl enable webapp
systemctl start webapp

echo "Setup completed successfully!"