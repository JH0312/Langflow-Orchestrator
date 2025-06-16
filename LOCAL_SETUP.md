
# Local Development Setup

This guide will help you run the LangFlow Workflow Orchestration System on any local machine for demonstration purposes.

## Prerequisites

- Node.js 20+ 
- Docker & Docker Compose
- PostgreSQL database (local or cloud)

## Quick Local Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
Create a `.env` file in the root directory:

```env
# Database Configuration
DATABASE_URL="postgresql://postgres:password@localhost:5432/langflow_orchestration"

# Server Configuration
NODE_ENV=development
PORT=5000

# Docker Services
LANGFLOW_URL=http://localhost:7860
REDIS_URL=redis://localhost:6379

# Security (generate your own secure keys)
SESSION_SECRET=your-secure-session-secret-here-minimum-32-chars
JWT_SECRET=your-secure-jwt-secret-here-minimum-32-chars

# Health Check Intervals
HEALTH_CHECK_INTERVAL=30
EXECUTION_TIMEOUT=300
LOG_LEVEL=info
```

### 3. Start Docker Services
```bash
docker-compose up -d
```

### 4. Initialize Database
```bash
npm run db:push
```

### 5. Start Development Server
```bash
npm run dev
```

### 6. Access the Application
- **Main Dashboard**: http://localhost:5000
- **LangFlow UI**: http://localhost:7860

## Project Structure Overview

```
├── client/                 # React frontend (TypeScript)
│   ├── src/components/    # UI components with shadcn/ui
│   ├── src/pages/         # Dashboard pages
│   └── src/lib/           # Utilities and configs
├── server/                # Express.js backend
│   ├── index.ts          # Server entry point
│   ├── routes.ts         # API endpoints
│   └── storage.ts        # Database layer
├── shared/               # Shared TypeScript types
├── docker-compose.yml    # LangFlow + Redis services
└── package.json          # Dependencies
```

## Key Features Demonstrated

- **AI Agent Management**: Email, PDF, JSON, Classifier agents
- **Real-time Monitoring**: Live execution tracking with SSE
- **Webhook Integration**: HTTP triggers for workflows
- **Cron Scheduling**: Time-based automation
- **Modern UI**: React dashboard with dark/light themes
- **Docker Integration**: Containerized AI services

## Tech Stack

- **Frontend**: React 18, TypeScript, Tailwind CSS, shadcn/ui
- **Backend**: Express.js, Node.js 20
- **Database**: PostgreSQL with Drizzle ORM
- **AI Services**: LangFlow (Docker), Redis
- **Real-time**: Server-Sent Events (SSE)

## Production Ready Features

- Environment-based configuration
- Database migrations with Drizzle
- Health monitoring for all services
- Comprehensive error handling
- TypeScript throughout
- Modern React patterns

## Troubleshooting

If Docker services fail to start:
```bash
docker-compose down
docker-compose up -d --force-recreate
```

If database connection fails, ensure PostgreSQL is running and DATABASE_URL is correct.

## Demo Data

The application includes sample workflows and execution data to demonstrate functionality without requiring external integrations.
