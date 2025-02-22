const express = require('express');
const MongoClient = require('mongodb').MongoClient; // MongoDB driver
const app = express();
const port = 3000;

// MongoDB connection URL and database name   
const mongoUrl = 'mongodb://aman:password@localhost:27017/amandb?authSource=amandb'; // Full DNS name inside Kubernetes
const dbName = 'amandb'; // The database name you set in your MongoDB values.yaml

// Middleware to parse incoming JSON requests
app.use(express.json());

// Connect to MongoDB
let db;

MongoClient.connect(mongoUrl)
  .then(client => {
    db = client.db(dbName); // Assign the MongoDB database
    console.log('Connected to MongoDB');
  })
  .catch(err => {
    console.error('Error connecting to MongoDB:', err);
  });

// Simple route
app.get('/', (req, res) => {
  res.send('Screw showing Hello World...I want to see if this will go from a basic script into a container, to a K8 which gets built via Helm charts and is then managed via Azure pipelines....but sure, hello world....');
});

// Another route for API (this will now interact with MongoDB)
app.get('/api', async (req, res) => {
  try {
    if (!db) throw new Error('Database not connected');
    const collection = db.collection('items');
    const items = await collection.find().toArray();
    res.json(items);
  } catch (err) {
    console.error('Error fetching items:', err);
    res.status(500).json({ message: 'Error fetching items from MongoDB' });
  }
});

// Route to add data to MongoDB
app.post('/api/items', async (req, res) => {
  try {
    if (!db) throw new Error('Database not connected');
    const collection = db.collection('items');
    const newItem = req.body;
    await collection.insertOne(newItem);
    res.status(201).json({ message: 'Item added successfully', item: newItem });
  } catch (err) {
    console.error('Error adding item:', err);
    res.status(500).json({ message: 'Error adding item to MongoDB', error: err.toString() });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
