# LangFlow Workflow Orchestration System

A comprehensive AI workflow orchestration platform that integrates LangFlow agents with Docker containerization, real-time monitoring, webhook triggers, and cron scheduling capabilities.

## 🚀 Quick Local Setup

For immediate local development (perfect for demonstrations):

```bash
# Clone and setup
npm install

# Create .env file (see LOCAL_SETUP.md for full configuration)
cp .env.example .env

# Start services
docker-compose up -d
npm run db:push
npm run dev
```

Access at: http://localhost:5000

📖 **See [LOCAL_SETUP.md](LOCAL_SETUP.md) for detailed setup instructions**

## 🚀 Features

### Core Functionality
- **AI Agent Management**: Support for Email, PDF, JSON, and Classifier agents
- **Real-time Monitoring**: Live execution tracking with SSE streaming
- **Webhook Integration**: HTTP triggers for automated workflow execution
- **Cron Scheduling**: Time-based workflow automation
- **Docker Integration**: Containerized LangFlow and Redis services
- **PostgreSQL Database**: Persistent data storage with Drizzle ORM

### Dashboard Features
- **Modern UI**: React-based dashboard with shadcn/ui components
- **Dark/Light Mode**: Theme switching with next-themes
- **Real-time Updates**: Server-sent events for live status updates
- **Execution Monitoring**: Detailed logs and performance metrics
- **Workflow Management**: Create, edit, and manage AI workflows
- **Health Monitoring**: Docker and Redis service health checks

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Client  │    │  Express Server │    │   PostgreSQL    │
│                 │◄──►│                 │◄──►│    Database     │
│  - Dashboard    │    │  - API Routes   │    │                 │
│  - Real-time UI │    │  - SSE Events   │    │  - Drizzle ORM  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │                       ▼
         │              ┌─────────────────┐    ┌─────────────────┐
         │              │   Docker Stack  │    │      Redis      │
         └──────────────►│                 │◄──►│                 │
                        │  - LangFlow AI  │    │  - Caching      │
                        │  - Port 7860    │    │  - Sessions     │
                        └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- **Node.js 20+**: JavaScript runtime
- **Docker & Docker Compose**: Container orchestration
- **PostgreSQL**: Database (can be local or cloud-hosted)
- **Git**: Version control

## 🛠️ Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd langflow-orchestration

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
```

### 2. Configure Environment

Edit `.env` file with your settings:

```env
# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/langflow_db"

# Server Configuration
NODE_ENV=development
PORT=5000

# Docker Services
LANGFLOW_URL=http://localhost:7860
REDIS_URL=redis://localhost:6379

# Security (generate secure keys)
SESSION_SECRET=your-session-secret-here
JWT_SECRET=your-jwt-secret-here
```

### 3. Start Services

```bash
# Start Docker services (LangFlow + Redis)
docker-compose up -d

# Initialize database
npm run db:push

# Start development server
npm run dev
```

### 4. Access the Application

- **Main Dashboard**: http://localhost:5000
- **LangFlow UI**: http://localhost:7860
- **Redis**: localhost:6379

## 📊 Database Schema

### Core Tables

#### Workflows
```sql
- id: Primary key
- name: Workflow name
- description: Optional description
- agentType: 'email' | 'pdf' | 'json' | 'classifier'
- configuration: JSON configuration
- status: 'active' | 'inactive' | 'archived'
- createdAt, updatedAt: Timestamps
```

#### Executions
```sql
- id: Primary key
- workflowId: Foreign key to workflows
- status: 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'
- triggerType: 'manual' | 'webhook' | 'cron'
- input, output: JSON data
- logs: Array of log entries
- progress: Execution progress (0-100)
- startTime, endTime: Execution timestamps
- duration: Execution time in milliseconds
```

#### Webhooks
```sql
- id: Primary key
- workflowId: Foreign key to workflows
- url: Unique webhook URL
- authMethod: 'none' | 'api_key' | 'bearer_token'
- authKey: Optional authentication key
- payloadSchema: JSON schema validation
- isActive: Boolean status
```

#### Cron Jobs
```sql
- id: Primary key
- workflowId: Foreign key to workflows
- expression: Cron expression
- timezone: Timezone (default UTC)
- startDate, endDate: Optional date range
- isActive: Boolean status
- retryFailed: Retry failed executions
- lastRun, nextRun: Execution timestamps
```

## 🔌 API Endpoints

### Workflows
- `GET /api/workflows` - List all workflows
- `GET /api/workflows/:id` - Get specific workflow
- `POST /api/workflows` - Create new workflow
- `PUT /api/workflows/:id` - Update workflow
- `DELETE /api/workflows/:id` - Delete workflow

### Executions
- `GET /api/executions` - List executions
- `GET /api/executions/active` - Get active executions
- `POST /api/executions` - Start execution
- `PUT /api/executions/:id` - Update execution status

### Webhooks
- `GET /api/webhooks` - List webhooks
- `POST /api/webhooks` - Create webhook
- `DELETE /api/webhooks/:id` - Delete webhook
- `POST /api/webhook/:id` - Trigger webhook

### Cron Jobs
- `GET /api/cron-jobs` - List cron jobs
- `POST /api/cron-jobs` - Create cron job
- `DELETE /api/cron-jobs/:id` - Delete cron job

### LangFlow Integration
- `GET /api/langflow/agents` - List available agents
- `GET /api/langflow/health` - Health check

### Real-time Updates
- `GET /api/sse` - Server-sent events stream

## 🎯 Agent Types

### Email Agent
- Process email content
- Extract information and metadata
- Support for attachments
- SMTP integration capabilities

### PDF Agent
- Extract text from PDF documents
- Process forms and structured data
- Handle multiple pages
- OCR capabilities for scanned documents

### JSON Agent
- Parse and validate JSON data
- Transform data structures
- API response processing
- Schema validation

### Classifier Agent
- Text classification
- Sentiment analysis
- Category assignment
- Machine learning predictions

## 📝 Usage Examples

### Creating a Workflow

```javascript
const workflow = {
  name: "Email Processing Pipeline",
  description: "Process incoming emails and extract key information",
  agentType: "email",
  configuration: {
    inputSchema: {
      email: "string",
      sender: "string",
      subject: "string"
    },
    outputSchema: {
      category: "string",
      priority: "number",
      extractedData: "object"
    }
  }
};

fetch('/api/workflows', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(workflow)
});
```

### Setting up a Webhook

```javascript
const webhook = {
  workflowId: 1,
  url: "/webhook/email-processor",
  authMethod: "api_key",
  authKey: "your-api-key",
  payloadSchema: {
    type: "object",
    properties: {
      email: { type: "string" },
      sender: { type: "string" }
    },
    required: ["email"]
  }
};

fetch('/api/webhooks', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(webhook)
});
```

### Creating a Cron Job

```javascript
const cronJob = {
  workflowId: 1,
  expression: "0 9 * * 1-5", // Every weekday at 9 AM
  timezone: "America/New_York",
  isActive: true,
  retryFailed: true
};

fetch('/api/cron-jobs', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(cronJob)
});
```

## 🔧 Development

### Project Structure

```
├── client/                 # React frontend
│   ├── src/
│   │   ├── components/    # UI components
│   │   ├── pages/         # Application pages
│   │   ├── lib/           # Utilities and configs
│   │   └── hooks/         # Custom React hooks
├── server/                # Express backend
│   ├── index.ts          # Server entry point
│   ├── routes.ts         # API routes
│   ├── storage.ts        # Data access layer
│   └── vite.ts           # Vite development setup
├── shared/               # Shared code
│   └── schema.ts         # Database schema and types
├── docker-compose.yml    # Docker services
└── package.json          # Dependencies and scripts
```

### Available Scripts

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server

# Database
npm run db:push      # Push schema changes
npm run db:studio    # Open Drizzle Studio

# Code Quality
npm run check        # TypeScript type checking
npm run lint         # ESLint checking
npm run format       # Prettier formatting
```

### Adding New Agent Types

1. **Update Schema** (`shared/schema.ts`):
```typescript
// Add to agentType enum
agentType: text("agent_type").notNull(), // Add new type here
```

2. **Create Agent Implementation**:
```typescript
// In server/agents/your-agent.ts
export class YourAgent {
  async process(input: any): Promise<any> {
    // Implementation logic
  }
}
```

3. **Register in Routes** (`server/routes.ts`):
```typescript
// Add handler for new agent type
case 'your-agent':
  result = await yourAgent.process(execution.input);
  break;
```

## 🚀 Deployment

### Production Setup

1. **Environment Configuration**:
```bash
NODE_ENV=production
DATABASE_URL=your-production-db-url
REDIS_URL=your-production-redis-url
```

2. **Build and Deploy**:
```bash
npm run build
npm run start
```

3. **Docker Production**:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Scaling Considerations

- **Database**: Use connection pooling for high-traffic scenarios
- **Redis**: Consider Redis Cluster for distributed caching
- **Load Balancing**: Use nginx or similar for multiple server instances
- **Monitoring**: Implement logging and monitoring solutions

## 🛡️ Security

- **Authentication**: JWT-based authentication system
- **Authorization**: Role-based access control
- **API Security**: Rate limiting and input validation
- **Database**: Prepared statements prevent SQL injection
- **Environment**: Secure environment variable management

## 📚 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Create GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub discussions for questions and community support

## 🔄 Changelog

### v1.0.0 (Current)
- Initial release with core orchestration features
- LangFlow integration
- Real-time monitoring dashboard
- Webhook and cron job support
- Docker containerization