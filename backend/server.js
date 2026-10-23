
const express = require('express');
const cors = require('cors');
const client = require('prom-client');
const path = require('path');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Prometheus metrics
const collectDefaultMetrics = client.collectDefaultMetrics;

collectDefaultMetrics({ register: client.register });

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, 'public')));

// Health check route
app.get('/', (req, res) => {
    res.send('Backend is running on port 5000!');
});

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
    try {
        res.setHeader('Content-Type', client.register.contentType);

        const metrics = await client.register.metrics();
        res.send(metrics);
    } catch (error) {
        console.error('Error fetching metrics:', error);
        res.status(500).send('Internal Server Error');
    }
});

// Start server
const PORT = process.env.PORT || 5000;

app.listen(PORT,'0.0.0.0', () => {
    console.log(`Server is listening on port ${PORT}`);
});

