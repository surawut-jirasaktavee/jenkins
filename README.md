# JENKINS

## Jenkins agents

Jenkins agents are the worker nodes that run the Jenkins jobs.

- **Master**: The Jenkins master is the main node that runs the Jenkins server.
- **Agent**: The Jenkins agent is a worker node that runs the Jenkins jobs. The agent can be a physical machine or a virtual machine.

### Types of Jenkins agents

There are two types of Jenkins agents:

- **Static agents**: The static agents are the worker nodes that are configured manually. The static agents are added to the Jenkins master manually.
- **Dynamic agents**: The dynamic agents are the worker nodes that are created automatically. The dynamic agents are created on-demand based on the workload.

### Jenkins agent setup

#### Jenkins agent setup with Docker

- [Jenkins agent setup with Docker](docs/docker-agent.md)

### Play with Jenkins

```bash
# Start Jenkins and Jenkins agent in detached mode
docker-compose up -d
```
