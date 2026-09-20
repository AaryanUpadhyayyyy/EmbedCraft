// Load .env only in development — in production (ECS Fargate), env vars come from
// Task Definition / AWS Secrets Manager, so dotenv is not needed
if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const cacheService = require('./src/services/cacheService');
const sqsService = require('./src/services/sqsService');
const nudgeRoutes = require('./src/routes/nudgeRoutes');
const authRoutes = require('./src/routes/authRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const campaignRoutes = require('./src/routes/campaignRoutes');
const metadataRoutes = require('./src/routes/metadataRoutes');

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" }
})); // Security headers with cross-origin allowed for images
app.use(cors()); // Enable CORS
app.use(express.json({ limit: '50mb' })); // Parse JSON bodies with higher limit for Lottie JSON
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// Disable caching for all admin/dashboard API routes
app.use((req, res, next) => {
    if (req.originalUrl.startsWith('/api/admin') || req.originalUrl.startsWith('/v1/admin')) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.setHeader('Surrogate-Control', 'no-store');
    }
    next();
});

// Health Check (Must be before routes to avoid auth middleware blocking)
// Enhanced for ECS container health monitoring — reports Redis + SQS status
app.get('/health', async (req, res) => {
    const redisStatus = await cacheService.ping();
    const mongoConnected = mongoose.connection.readyState === 1;
    
    const isHealthy = mongoConnected; // MongoDB must be connected; Redis is optional due to fallback mode.
    
    res.status(isHealthy ? 200 : 503).json({
        status: isHealthy ? 'ok' : 'error',
        timestamp: new Date(),
        services: {
            redis: redisStatus,
            sqs: sqsService.isEnabled() ? 'enabled' : 'disabled (local mode)',
            mongodb: mongoConnected ? 'connected' : 'disconnected',
        }
    });
});

// Public Routes (No auth required)
app.use('/api/support', require('./src/routes/supportRoutes')); // Support/Contact Form (Public)

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/v1/admin/campaigns', campaignRoutes); // Dashboard Campaign API
app.use('/v1/admin/metadata', metadataRoutes); // Dashboard Metadata API (Events & Properties)
app.use('/v1/admin/datasources', require('./src/routes/dataSourceRoutes')); // Data Sources Registry API
app.use('/v1/admin/rewards', require('./src/routes/rewards')); // Gamification Reward Vault API
app.use('/v1/admin/analytics', require('./src/routes/analyticsRoutes')); // Dashboard Analytics API
app.use('/v1/admin/assets', require('./src/routes/assetRoutes')); // Dashboard Assets API
app.use('/v1/admin/team', require('./src/routes/teamRoutes')); // Dashboard Team API
app.use('/v1/admin/organization', require('./src/routes/organizationRoutes')); // Dashboard Organization Settings API
app.use('/v1', require('./src/routes/segmentRoutes')); // Segments API
app.use('/v1', require('./src/routes/flowRoutes')); // Flows API
app.use('/v1', require('./src/routes/templateRoutes')); // Templates API
app.use('/', nudgeRoutes);
app.use('/api/pages', require('./src/routes/pageRoutes')); // Page Feature API

// Database Connection with Production-Grade Pooling for 100M Users
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nudge_db';

const mongoOptions = {
    maxPoolSize: 100,        // Max connections (was 5 - now 20x more!)
    minPoolSize: 10,         // Min connections to keep open
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
    family: 4,               // Use IPv4
    maxIdleTimeMS: 60000,   // Close idle connections after 1 min
    compressors: 'zlib'      // Enable compression
};

mongoose.connect(MONGO_URI, mongoOptions)
    .then(() => {
        console.log('✅ MongoDB Connected');
        console.log(`📊 Connection Pool: ${mongoOptions.minPoolSize}-${mongoOptions.maxPoolSize} connections`);
    })
    .catch(err => console.error('❌ MongoDB Connection Error:', err));

// Monitor connection health
mongoose.connection.on('connected', () => {
    console.log('🔗 MongoDB connection established');
});

mongoose.connection.on('error', (err) => {
    console.error('❌ MongoDB error:', err);
});

mongoose.connection.on('disconnected', () => {
    console.warn('⚠️ MongoDB disconnected - attempting reconnect...');
});


// Start Server
const server = app.listen(PORT, () => {
    console.log(`🚀 Nudge Backend running on port ${PORT}`);
});

// Graceful shutdown — ECS sends SIGTERM before stopping containers
const gracefulShutdown = async (signal) => {
    console.log(`\n${signal} received. Shutting down gracefully...`);
    server.close(async () => {
        console.log('🔌 HTTP server closed');
        await cacheService.disconnect();
        await mongoose.connection.close();
        console.log('✅ All connections closed. Exiting.');
        process.exit(0);
    });
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
