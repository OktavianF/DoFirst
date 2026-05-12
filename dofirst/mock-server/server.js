const express = require('express');
const cors = require('cors');
const multer = require('multer');

const app = express();
app.use(cors());
app.use(express.json());
const upload = multer({ storage: multer.memoryStorage() });

const PORT = 3000;
let completedTasks = 2;

// Logging middleware
app.use((req, res, next) => {
    console.log(`[Mock Server] ${req.method} ${req.url}`);
    next();
});

// --- AUTH MOCKS ---
app.post('/api/auth/login', (req, res) => {
    res.json({
        data: {
            access_token: 'mock-access-token-12345',
            refresh_token: 'mock-refresh-token-12345',
            user: {
                id: '1',
                email: req.body.email || 'test@example.com',
                name: 'Mock User',
            }
        }
    });
});

app.post('/api/auth/signup', (req, res) => {
    res.json({
        data: {
            access_token: 'mock-access-token-12345',
            refresh_token: 'mock-refresh-token-12345',
            user: {
                id: '1',
                email: req.body.email || 'test@example.com',
                name: req.body.name || 'New Mock User',
            }
        }
    });
});

app.get('/api/auth/me', (req, res) => {
    res.json({
        data: {
            id: '1',
            email: 'test@example.com',
            name: 'Mock User',
        }
    });
});

// --- DASHBOARD MOCKS ---
app.get('/api/dashboard', (req, res) => {
    res.json({
        data: {
            total_tasks: tasks.length + completedTasks,
            completed_tasks: completedTasks,
            productivity_score: 85,
            recent_activities: []
        }
    });
});

// --- TASK MOCKS ---
let tasks = [
    {
        id: 't1',
        title: 'Complete Mobile App UI',
        description: 'Finish all Flutter screens.',
        score: 9.5,
        priority: 'High',
        importance: 4,
        difficulty: 3,
        urgency: 5,
        deadline: new Date(Date.now() + 86400000).toISOString() // tomorrow
    },
    {
        id: 't2',
        title: 'Review Mock Server',
        description: 'Test the mock server integration.',
        score: 6.0,
        priority: 'Medium',
        importance: 3,
        difficulty: 2,
        urgency: 4,
        deadline: new Date(Date.now() + 172800000).toISOString() // 2 days
    }
];

app.get('/api/tasks', (req, res) => {
    res.json({ data: tasks });
});

app.post('/api/tasks', upload.single('attachment'), (req, res) => {
    const importance = Number(req.body.importance ?? 3);
    const difficulty = Number(req.body.difficulty ?? 3);
    const urgency = Number(req.body.urgency ?? 3);

    const attachment = req.file
        ? {
            field: req.file.fieldname,
            name: req.file.originalname,
            mimeType: req.file.mimetype,
            size: req.file.size,
        }
        : null;

    const newTask = {
        id: 't' + Date.now(),
        title: req.body.title,
        description: req.body.description,
        score: 7.5,
        priority: 'Medium',
        importance,
        difficulty,
        urgency,
        deadline: req.body.deadline,
        tags: req.body.tags || [],
        attachments: attachment ? [attachment] : []
    };
    tasks.push(newTask);
    res.json({ data: newTask });
});

app.get('/api/tasks/:id', (req, res) => {
    const task = tasks.find(t => t.id === req.params.id);
    if (task) {
        res.json({ data: task });
    } else {
        res.status(404).json({ error: 'Task not found' });
    }
});

app.delete('/api/tasks/:id/complete', (req, res) => {
    tasks = tasks.filter(t => t.id !== req.params.id);
    completedTasks += 1;
    res.json({ data: { success: true } });
});

app.listen(PORT, () => {
    console.log(`Mock Backend Server is running at http://localhost:${PORT}/api`);
});
