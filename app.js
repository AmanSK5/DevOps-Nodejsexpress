const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;

// MongoDB connection details from .env
const mongoUrl = process.env.MONGOURI;
const dbName = process.env.DBNAME;

// Middleware to parse incoming JSON requests
app.use(express.json());

let db; // Global variable for database reference

async function connectDB() {
  try {
    const client = new MongoClient(mongoUrl);
    await client.connect();
    db = client.db(dbName);
    console.log(`✅ Connected to MongoDB database: ${dbName}`);

    // Start the server AFTER database connection is established
    app.listen(port, () => {
      console.log(`🚀 Server is running at http://localhost:${port}`);
    });
  } catch (err) {
    console.error('❌ MongoDB Connection Error:', err);
    process.exit(1); // Exit process if DB connection fails
  }
}

// Connect to MongoDB
connectDB();

// API route to fetch items
app.get('/api/items', async (req, res) => {
  try {
    if (!db) return res.status(500).json({ message: 'Database not connected' });

    const collection = db.collection('items');
    const items = await collection.find().toArray();
    res.json(items);
  } catch (err) {
    console.error('Error fetching items:', err);
    res.status(500).json({ message: 'Error fetching items from MongoDB' });
  }
});

// Simple route
app.get('/', (req, res) => {
  res.send('Screw showing Hello World...I want to see if this will go from a basic script into a container, to a K8 which gets built via Helm charts and is then managed via Azure pipelines....but sure, hello world....');
});

// API route to add an item
app.post('/api/items', async (req, res) => {
  try {
    if (!db) return res.status(500).json({ message: 'Database not connected' });

    const collection = db.collection('items');
    const newItem = req.body;
    await collection.insertOne(newItem);
    res.status(201).json({ message: 'Item added successfully', item: newItem });
  } catch (err) {
    console.error('Error adding item:', err);
    res.status(500).json({ message: 'Error adding item to MongoDB', error: err.toString() });
  }
});

// Route for '/api' to show all items
app.get('/api', async (req, res) => {
  try {
    if (!db) return res.status(500).json({ message: 'Database not connected' });

    const collection = db.collection('items');
    const items = await collection.find().toArray();
    res.json(items); // Send all items
  } catch (err) {
    console.error('Error fetching items:', err);
    res.status(500).json({ message: 'Error fetching items from MongoDB' });
  }
});

// Route for '/api/list' to show all items
app.get('/api/list', async (req, res) => {
  try {
    if (!db) return res.status(500).json({ message: 'Database not connected' });

    const collection = db.collection('items');
    const items = await collection.find().toArray();
    res.json(items); // Send all items
  } catch (err) {
    console.error('Error fetching items:', err);
    res.status(500).json({ message: 'Error fetching items from MongoDB' });
  }
});
