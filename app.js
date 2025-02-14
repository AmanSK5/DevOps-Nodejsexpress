const express = require('express');
const app = express();
const port = 3000;

// Simple route
app.get('/', (req, res) => {
  res.send('Screw showing Hello World...I want to see if this will go from a basic script into a container, to a K8 which gets built via Helm charts and is then managed via Azure pipelines....but sure, hello world....');
});

// Another route for API
app.get('/api', (req, res) => {
  res.json({ message: 'This is a simple Node.js API.' });
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});