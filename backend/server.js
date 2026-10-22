const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
const path = require("path");

app.use(express.static(path.join(__dirname, "public")));

app.get('/', (req, res) => {
    res.send('Backend is running 5000!');
});

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server is listening on port 5000`);
});

