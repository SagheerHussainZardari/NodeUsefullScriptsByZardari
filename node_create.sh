# make directory and cd into it
mkdir $1 && cd $1

# project and basic package installation
npm init -y && npm i express nodemon mongoose dotenv body-parser

# creating env file
echo 'PORT=3000' > .env
echo 'DB_NAME=""' >> .env
echo 'DB_USER=""' >> .env
echo 'DB_PASSWORD=""' >> .env
echo 'MONGO_URI=""' >> .env

# creating server file
echo 'import express from "express";
import dotenv from "dotenv";
import bodyParser from "body-parser";

const app = express();
dotenv.config();
app.use(bodyParser.json());

app.get("/",(req,res) =>{
    res.send("Happy Coding...")
});

app.listen(process.env.PORT || 3000, ()=>{
    console.log("Server running on http://127.0.0.1:"+process.env.PORT);
});' > index.js


# after this add start script in package.json and type module