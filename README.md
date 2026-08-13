# BK Corp Club SaaS - Frontend

Modern React + Vite frontend for BK Corp Club multi-tenant SaaS platform.

## Quick Start

### Prerequisites
- Node.js 18+ installed
- Backend running on `http://localhost:3000`

### Installation

```bash
npm install
npm run dev
```

Open `http://localhost:5173` in your browser.

## Project Structure

```
src/
├── api/          # API client with endpoints
├── contexts/     # React contexts (Auth)
├── pages/        # Page components
├── App.jsx       # Main app component
├── main.jsx      # Entry point
└── index.css     # Global styles
```

## Security

Development/admin credentials are not documented in the repository. Use the configured environment/bootstrap process for authorized access.

## Build

```bash
npm run build
```

## Features

- Multi-tenant authentication
- Dashboard with real-time stats
- API client with interceptors
- Protected routes
- Responsive design
- Error handling
