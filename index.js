const express = require('express');
const cors = require('cors');
const app = express();

const port = 3000;

// Global Middleware
app.use(cors());

app.get('/', (req, res) => {
    res.send('Start Sample app with Docker configuration and Bash ');
});


app.listen(port, () => {
    console.log('Example app listening on port port!', port);
});

//Run app, then load http://localhost:port in a browser to see the output.