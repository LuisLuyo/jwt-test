const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

//middleware
app.use(express.json());
app.use(express.urlencoded({extended : false}));


app.get('/', );

app.post('/api/login',(req,res)=>{
    const user = {id:3};
    //debo obtener el usuario y contraseña insertado desde el body
    //aqui debo acceder a la base de datos a Validar el usuario y la contraseña ingresada
    //según sea la respuesta debo validar si se genera o no el token
    const token = jwt.sign({user}, 'my_secret_key', { expiresIn: '30s' });
    res.json({
        token
    });
});

app.get('/api/protected', ensureToken, (req,res)=>{
    jwt.verify(req.token,'my_secret_key',(err,data) => {
        if(err){
            res.sendStatus(403)
        }else{
            res.json({
                text : 'protected',
                data
            });
        }
    })
});

function ensureToken(req, res, next){
    const bearerHeader = req.headers['authorization'];
    if(typeof bearerHeader !== 'undefined'){
        const bearer = bearerHeader.split(' ');
        const bearerToken = bearer[1];
        req.token = bearerToken;
        next();
    }else{
        res.sendStatus(403);
    }

}

app.use(require('./routes/index'));

app.listen(4000,() => {
    console.log('Server on port 4000!')
});