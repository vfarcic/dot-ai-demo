# Infrastructure Setup Intent Gathering

**IMPORTANT:** When executing this prompt, do NOT use any MCP (Model Context Protocol) tools or services. Use only standard Claude tools like Bash, Read, Write, Edit, etc. to implement the infrastructure setup.

**WORKFLOW:** Ask ALL questions below in the specified order before starting any implementation. Do NOT modify these questions. Only proceed with implementation after collecting all answers.

## Step 1: Intent Question

Ask the user: "What do you want to deploy or set up? Please describe your intent for setting up infrastructure resources."

Examples you can provide:
- Deploy a web application with database
- Set up a Kubernetes cluster
- Create a PostgreSQL database
- Deploy a microservices architecture
- Set up monitoring and logging
- Create a CI/CD pipeline

## Step 2: Required Questions

Ask these questions exactly as written:

1. "What type of resource/application are you deploying?"
   Options: Database (PostgreSQL, MySQL, MongoDB, etc.) | Web Application (Frontend, Backend, Full-stack) | Container/Kubernetes workload | Storage solution | Networking component | Monitoring/Observability tool | Other

2. "Which cloud provider or platform?"
   Options: AWS | Azure | Google Cloud | Kubernetes cluster | On-premises | Docker/Local | Other

3. "What environment is this for?"
   Options: Development | Staging | Production | Testing

## Step 3: Basic Questions

Ask these questions exactly as written:

1. "What are your performance requirements?"
   Ask for: Expected traffic/load, Storage needs, Memory requirements

2. "Do you need high availability?"
   Options: Yes - Multi-region/zone | Yes - Single region, multiple zones | No - Single instance is fine

3. "What's your preferred naming convention?"
   Ask for: Resource prefix, Environment suffix

4. "Do you need backup and disaster recovery?"
   Options: Yes - Automated backups | Yes - Manual backups | No

## Step 4: Advanced Questions

Ask these questions exactly as written:

1. "What are your security and compliance requirements?"
   Ask about: Encryption at rest | Encryption in transit | VPC/Private networking | Specific compliance standards

2. "What monitoring and alerting do you need?"
   Ask about: Application metrics | Infrastructure metrics | Log aggregation | Alert notifications (email, Slack, etc.)

3. "What are your scaling preferences?"
   Ask about: Auto-scaling enabled | Manual scaling only | Specific scaling triggers

4. "What are your integration requirements?"
   Ask for: External services to connect, Authentication method, API requirements

## Step 5: Open Questions

Ask these questions exactly as written:

1. "Do you have any custom configurations or special requirements?"

2. "Are there any budget constraints or cost considerations?"

3. "What's your timeline for deployment?"

4. "Who needs access and what level of permissions do they need?"

5. "Any additional notes, preferences, or constraints?"

## Step 6: Implementation

ONLY after collecting answers to ALL questions above, proceed with the implementation using the gathered requirements. Create a comprehensive plan and execute it step by step.