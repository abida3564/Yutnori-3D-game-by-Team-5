# Yutnori Sound Vision API

Node.js + Express + Socket.io backend with **InfinityFree MySQL** for registration, friends, rooms, rematch, scores, and global leaderboard.

## Quick start

```bash
cd api
cp .env.example .env   # fill in MYSQL_* credentials
npm install
npm start
```

API base (local): `http://localhost:8787/api`  
Health: `GET http://localhost:8787/api/health` (includes DB check)  
Sockets: path `/api/socket.io`

## MySQL setup (InfinityFree)

1. Open **phpMyAdmin** on your InfinityFree panel.
2. Select database `if0_42509113_game_loop` (or your DB name).
3. Import `api/schema.sql` (or let the API auto-create tables on first boot).
4. Copy credentials into `api/.env`:

```env
MYSQL_HOST=sql103.infinityfree.com
MYSQL_PORT=3306
MYSQL_USER=if0_42509113
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=if0_42509113_game_loop
```

### Remote MySQL access

InfinityFree MySQL is usually reachable only from:

- PHP scripts on the same InfinityFree account, or
- External hosts if **Remote MySQL** is enabled in the control panel and your server IP is whitelisted.

If you host the Node API on **VPS / Railway / Render** (recommended), add that server's public IP under **Remote MySQL** in InfinityFree, then point `MYSQL_*` at `sql103.infinityfree.com`.

> InfinityFree free hosting does **not** run long-lived Node.js. Keep the game static files on InfinityFree (or any host) and run this API on a Node-capable server that connects to InfinityFree MySQL.

## Environment

| Variable | Default | Meaning |
|---|---|---|
| `PORT` | `8787` | HTTP port |
| `CORS_ORIGIN` | `*` | Comma-separated allowed origins, or `*` |
| `MYSQL_HOST` | — | MySQL hostname |
| `MYSQL_PORT` | `3306` | MySQL port |
| `MYSQL_USER` | — | MySQL username |
| `MYSQL_PASSWORD` | — | MySQL password |
| `MYSQL_DATABASE` | — | Database name |

## Production (`https://gameloop.gamer.free/api`)

InfinityFree / PHP-only hosts **cannot** run this Node + Socket.io API.
Run the API on a Node host (Railway, Render, VPS), then point `gameloop.gamer.free` at it.

### Option A — Railway (easiest free Node host)

1. Create account at [railway.app](https://railway.app)
2. **New Project → Deploy from GitHub** (or upload the `api/` folder)
3. Set **Root Directory** to `api`
4. Add variables (same as `.env`):

```
PORT=8787
CORS_ORIGIN=*
MYSQL_HOST=sql103.infinityfree.com
MYSQL_PORT=3306
MYSQL_USER=if0_42509113
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=if0_42509113_game_loop
```

5. Start command: `npm start`
6. In InfinityFree → **Remote MySQL** → whitelist Railway’s public IP (or allow `%` if the panel allows)
7. Custom domain: add `gameloop.gamer.free` in Railway → set DNS CNAME to Railway’s domain
8. Test: open `https://gameloop.gamer.free/api/health` → should show `{ "ok": true, "db": "mysql" }`

### Option B — VPS with nginx

1. Run this process with pm2: `cd api && npm start`
2. Set `api/.env` with InfinityFree MySQL credentials.
3. Reverse-proxy HTTPS to Node:

```nginx
location /api/ {
  proxy_pass http://127.0.0.1:8787/api/;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "upgrade";
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
}
```

4. Frontend `API_BASE` is `https://gameloop.gamer.free/api`.

## Database tables

| Table | Stores |
|---|---|
| `players` | User accounts, Friend ID, wins/games, presence |
| `friendships` | Friend requests and accepted friends |
| `rooms` | Online room metadata + live game state (JSON) |
| `room_seats` | Seat assignments and rematch votes |
| `matches` | Finished match history |

## Main endpoints

- `POST /api/register` `{ name }`
- `GET|PATCH /api/me`
- `POST /api/presence` `{ status }`
- `GET /api/friends` · `POST /api/friends/request` · `POST /api/friends/respond` · `DELETE /api/friends/:playerId`
- `POST /api/rooms` · `POST /api/rooms/join` · `GET /api/rooms/:code`
- `POST /api/rooms/:code/start|leave|invite|rematch`
- `GET /api/leaderboard`

Auth: `Authorization: Bearer <sessionToken>`
