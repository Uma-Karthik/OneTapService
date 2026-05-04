# MongoDB Setup Guide

## Option 1: MongoDB Atlas (Cloud - Recommended for Production)

### Step 1: Create Account
1. Visit https://www.mongodb.com/cloud/atlas
2. Sign up for free account
3. Create organization & project

### Step 2: Create a Cluster
1. Click "Create" button
2. Select "Shared" (Free tier)
3. Choose cloud provider (AWS recommended)
4. Select region closest to you
5. Click "Create Cluster"

### Step 3: Configure Network Access
1. Go to "Network Access" in left sidebar
2. Click "Add IP Address"
3. Click "Allow Access from Anywhere" (or restrict to your IP)
4. Click "Confirm"

### Step 4: Create Database User
1. Go to "Database Access" in left sidebar
2. Click "Add New Database User"
3. Create username: `admin`
4. Create strong password (save it!)
5. Click "Add User"

### Step 5: Get Connection String
1. Click "Connect" button on your cluster
2. Select "Drivers"
3. Choose Node.js driver
4. Copy the connection string:
```
mongodb+srv://admin:<PASSWORD>@cluster0.xxxxx.mongodb.net/home_services?retryWrites=true&w=majority
```

### Step 6: Update .env
Replace `<PASSWORD>` with your password and add to `.env`:
```
MONGODB_URI=mongodb+srv://admin:your_password_here@cluster0.xxxxx.mongodb.net/home_services?retryWrites=true&w=majority
```

---

## Option 2: Local MongoDB (Windows)

### Step 1: Download & Install
1. Download MongoDB Community from: https://www.mongodb.com/try/download/community
2. Run installer
3. Choose "Complete" installation
4. Install MongoDB Compass (GUI tool - optional but recommended)

### Step 2: Start MongoDB Service
```powershell
# MongoDB should auto-start on Windows
# If not, open Services and look for "MongoDB Server"
# Or start manually:
mongod --dbpath "C:\data\db"
```

### Step 3: Verify Connection
```bash
mongosh  # or mongo for older versions
```

### Step 4: Update .env
```
MONGODB_URI=mongodb://127.0.0.1:27017/home_services
```

---

## Option 3: Docker (Advanced)

### Start MongoDB in Docker:
```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### Update .env:
```
MONGODB_URI=mongodb://localhost:27017/home_services
```

---

## 🧪 Testing Database Connection

### Test 1: Health Check Endpoint
```bash
curl http://localhost:5000/health
```

**Success Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2026-02-25T12:00:00.000Z"
}
```

### Test 2: Quick Registration Test
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@test.com",
    "password": "TestPass123",
    "phone": "1234567890",
    "address": "123 Test St",
    "role": "customer"
  }'
```

---

## 🔍 Troubleshooting

### Connection Refused Error
**Problem:** `ECONNREFUSED 127.0.0.1:27017`
**Solution:** 
- Make sure MongoDB is running: `mongod`
- Check that port 27017 is not blocked
- If using Atlas, verify IP whitelist settings

### Authentication Failed
**Problem:** Invalid username/password
**Solution:**
- Verify credentials in .env
- Reset password in MongoDB Atlas if needed
- Check database user has correct permissions

### Slow Connection
**Problem:** Server takes long time to start
**Solution:**
- Verify internet connection (for Atlas)
- Check server location (choose nearest region)
- Reduce `serverSelectionTimeoutMS` in server.js if desired

---

## ✅ Verify Installation

After MongoDB is running and connected:

```bash
# Terminal 1: Start server
cd backend
npm start

# Should see:
# ✅ Successfully connected to MongoDB
# 🚀 Server is running on port 5000
# 📡 Socket.io is active
```

```bash
# Terminal 2: Test API
curl http://localhost:5000/health

# Should show:
# {"status":"healthy","database":"connected",...}
```

---

## 📊 Database Structure

Once MongoDB is connected, the following collections will be created automatically:

- **users** - Stores customer and provider accounts
- **providers** - Stores provider profiles
- **services** - Stores service listings
- **bookings** - Stores booking records

All collections have proper indexing for performance.

---

**After setting up MongoDB, restart the server and all features will be fully functional!**
