# Mern-Linux 🚀

**A MERN Stack Practice Project using WSL, Linux, Docker, and Docker Compose**

Mern-Linux is a hands-on learning project designed to practice full-stack web development in a Linux environment using **WSL (Windows Subsystem for Linux)**. It combines MongoDB, Express.js, React.js, Node.js, and Docker to help build a practical development and deployment workflow.

## 📌 Project Overview

* **Frontend:** React.js with Vite
* **Backend:** Node.js and Express.js
* **Database:** MongoDB
* **Containerization:** Docker
* **Container Orchestration:** Docker Compose
* **Development Environment:** WSL 2 with Ubuntu
* **Version Control:** Git and GitHub

## 🎯 Learning Objectives

* Practice Linux commands using WSL Ubuntu.
* Build and run a MERN stack application.
* Understand frontend and backend communication.
* Create Dockerfiles for frontend and backend.
* Run multiple services using Docker Compose.
* Configure environment variables and networking.
* Learn container logs, debugging, and persistent storage.
* Practice Git and GitHub workflows.

## 📁 Project Structure

```text
Mern-Linux/
├── frontend/
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
│
├── backend/
│   ├── src/
│   │   └── server.js
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
│
├── docker-compose.yaml
├── .gitignore
└── README.md
```

The frontend contains the user interface, the backend handles API requests, and MongoDB stores application data.

## 🛠️ Prerequisites

Install or configure the following tools:

* Windows 10/11 with WSL 2
* Ubuntu on WSL
* Node.js and npm
* Git
* Docker Desktop with WSL integration enabled

Verify the Linux environment:

```bash
wsl --status
wsl -l -v
```

Open Ubuntu and verify the development tools:

```bash
uname -a
lsb_release -a
node --version
npm --version
git --version
docker --version
docker compose version
```

If Node.js or Git is missing, install them inside Ubuntu before continuing. Docker commands should work after enabling Docker Desktop's WSL integration, or after configuring an alternative Docker Engine inside Linux.

## 🚀 Getting Started

### 1. Open WSL Ubuntu

Open your Ubuntu terminal and navigate to your Linux home directory:

```bash
cd ~
mkdir -p Mern-Linux
cd Mern-Linux
```

**Tip:** Keep your development project inside the WSL Linux filesystem, such as `~/Mern-Linux`, rather than `/mnt/c/Users/...`. This generally provides better performance for Linux-based development tools.

### 2. Create the Frontend

Create a React application using Vite:

```bash
npm create vite@latest frontend -- --template react
cd frontend
npm install
cd ..
```

### 3. Create the Backend

Initialize the Node.js project:

```bash
mkdir -p backend/src
cd backend
npm init -y
npm install express mongoose cors dotenv
npm install --save-dev nodemon
```

Add the following scripts to the `scripts` section of `backend/package.json`:

```json
"scripts": {
  "start": "node src/server.js",
  "dev": "nodemon src/server.js"
}
```

Create `backend/src/server.js`:

```javascript
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    message: "Mern-Linux backend is running!",
    status: "success"
  });
});

app.get("/api/health", (req, res) => {
  res.json({ status: "ok" });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend running on port ${PORT}`);
});
```

Return to the project root:

```bash
cd ..
```

## 🐳 Docker Configuration

### 4. Backend Dockerfile

Create `backend/Dockerfile`:

```dockerfile
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

ENV NODE_ENV=production
ENV PORT=5000

EXPOSE 5000

CMD ["npm", "start"]
```

### 5. Frontend Dockerfile

Create `frontend/Dockerfile`:

```dockerfile
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

This uses a multi-stage build: Vite builds the React application, and Nginx serves the resulting static files.

### 6. Docker Ignore Files

Create `frontend/.dockerignore`:

```text
node_modules
dist
.git
.env
```

Create `backend/.dockerignore`:

```text
node_modules
.git
.env
npm-debug.log
```

These files prevent unnecessary files and local secrets from being copied into Docker images.

### 7. Docker Compose

Create `docker-compose.yaml` in the project root:

```yaml
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    depends_on:
      - backend
    restart: unless-stopped

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      PORT: 5000
      MONGODB_URI: mongodb://mongo:27017/mern_linux
    depends_on:
      - mongo
    restart: unless-stopped

  mongo:
    image: mongo:7
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped

volumes:
  mongo_data:
```

**Important:** This is the initial practice configuration. The MongoDB container is included, but database connection logic still needs to be added to `server.js` before the backend can use MongoDB. Also, the frontend and backend need API integration for a complete application.

## ▶️ Run the Project

From the `Mern-Linux` root directory, build and start the containers:

```bash
docker compose up --build
```

Open the following URLs in your Windows browser:

| Service              | URL                              |
| -------------------- | -------------------------------- |
| React frontend       | http://localhost:3000            |
| Backend API          | http://localhost:5000            |
| Backend health check | http://localhost:5000/api/health |

Check the running containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
```

View logs for an individual service:

```bash
docker compose logs -f frontend
docker compose logs -f backend
docker compose logs -f mongo
```

Stop the services:

```bash
docker compose down
```

Stop the services and remove the MongoDB data volume:

```bash
docker compose down -v
```

**Warning:** The second command deletes the persistent MongoDB volume created by this Compose project. Use it only when you intentionally want to remove the stored database data.

## 🧪 Run Without Docker

For local development, start MongoDB separately or use a MongoDB container, then run the backend:

```bash
cd backend
npm install
npm run dev
```

In another Ubuntu terminal, start the frontend:

```bash
cd ~/Mern-Linux/frontend
npm install
npm run dev -- --host 0.0.0.0
```

The Vite development server will typically be available at:

http://localhost:5173

For local development, configure the frontend API URL to point to `http://localhost:5000`. When the frontend runs inside a container, remember that `localhost` refers to that container itself. Container-to-container communication should use the Compose service name, such as `http://backend:5000`, where appropriate.

## 🐧 Linux Commands to Practice

| Command                                 | Purpose                            |
| --------------------------------------- | ---------------------------------- |
| `pwd`                                   | Display the current directory      |
| `ls -la`                                | List files, including hidden files |
| `cd ..`                                 | Move to the parent directory       |
| `mkdir -p folder`                       | Create a directory                 |
| `touch file.txt`                        | Create an empty file               |
| `cat file.txt`                          | Display file contents              |
| `grep "error" file.txt`                 | Search for matching text           |
| `ps aux`                                | Display running processes          |
| `df -h`                                 | Check disk usage                   |
| `chmod +x script.sh`                    | Make a script executable           |
| `curl http://localhost:5000/api/health` | Test the backend endpoint          |

## 🔧 Troubleshooting

### Docker command not found

Verify Docker Desktop is running and WSL integration is enabled for your Ubuntu distribution.

```bash
docker --version
docker compose version
```

### Port already in use

Check whether a process is already listening on a port:

```bash
ss -ltnp
```

Change the host-side port mapping in `docker-compose.yaml` if necessary.

### Container exits unexpectedly

Inspect the service logs:

```bash
docker compose logs backend
docker compose logs frontend
```

### Changes are not reflected

Rebuild the affected service:

```bash
docker compose up --build
```

### MongoDB data disappears

Ensure the Compose file includes the named volume `mongo_data` and avoid running `docker compose down -v` unless you intend to delete that data.

## 📈 Future Improvements

* [ ] Connect Express to MongoDB using Mongoose.
* [ ] Add CRUD APIs.
* [ ] Build React forms and API integration.
* [ ] Add input validation and centralized error handling.
* [ ] Implement authentication and authorization.
* [ ] Add environment-specific configuration.
* [ ] Add Docker health checks.
* [ ] Add automated tests.
* [ ] Implement GitHub Actions CI/CD.
* [ ] Deploy the application to AWS.
* [ ] Add monitoring using Prometheus and Grafana.
* [ ] Explore Kubernetes deployment.

## 👨‍💻 Author

**Prince Kumar**

* GitHub: [Princekumarsahu-321](https://github.com/Princekumarsahu-321)
* LinkedIn: [Prince Kumar](https://www.linkedin.com/in/prince-kumar-36a88035b/)

## 📄 License

This project is intended for learning and practice. Add an appropriate open-source license if you decide to distribute it publicly.

---

**Mern-Linux: Learn Linux, build with MERN, and ship with Docker.** 🚀
