const express = require('express');
const app = express();
require('dotenv').config({path: __dirname + '/.env'})

//middleware
app.use(express.urlencoded({extended: false}));
app.use(express.json());

//app.use('/api/auth',require('./controllers/authController'));
app.use(require('./routes/index'));

module.exports = app;