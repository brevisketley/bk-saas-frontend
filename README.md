# BK Corp Club SaaS - Frontend

Modern React + Vite frontend for BK Corp Club multi-tenant SaaS platform.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- Backend running on `http://localhost:3000`

### Installation

```bash
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

## 📁 Project Structure

```
src/
├── api/          # API client with endpoints
├── contexts/     # React contexts (Auth)
├── pages/        # Page components
├── App.jsx       # Main app component
├── main.jsx      # Entry point
└── index.css     # Global styles
```

## 🔐 Default Login

- **Tenant ID**: `bk-corp-club`
- **Email**: `admin@bkcorpclub.com`
- **Password**: `Admin@2024!`

## 📦 Build

```bash
npm run build
```

## 🔍 Features

- ✅ Multi-tenant authentication
- ✅ Dashboard with real-time stats
- ✅ API client with interceptors
- ✅ Protected routes
- ✅ Responsive design
- ✅ Error handling
