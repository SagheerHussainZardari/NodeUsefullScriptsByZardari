# RUN THIS FILE USING "chmod +x node_modules.sh" and than ./node_modules.sh projectName (project is name is optional here)

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
import userRouter from "./src/routes/user.route.js";
import connection from "./connection.js";


const app = express();
dotenv.config();
app.use(bodyParser.json());

app.use("/users",userRouter);

app.get("*",(req,res) =>{
    res.send("404");
});

app.listen(process.env.PORT || 3000, ()=>{
    console.log("Server running on http://127.0.0.1:"+process.env.PORT);
});' > index.js

# creates connection file

echo 'import mongoose from "mongoose";


const connection = mongoose.connect("mongodb://localhost:27017/node-practise-1",{
    
}).then(()=>{
    console.log("Connected to database successfully");
}).catch((err)=>{
    console.log("Connection Failed ", err);
});

export default connection;' > connection.js

mkdir src

#make src/models
mkdir src/models
#creates User Model
echo 'import mongoose from "mongoose";
import  {Schema}  from "mongoose";

const userSchema = new Schema({
    name: String
});

const User = mongoose.model("user", userSchema);

export default User;' > src/models/user.model.js

mkdir src/routes
#create User Routes
echo 'import { Router } from "express";
import UserService from "../services/user.service.js"
const userRouter = new Router()


userRouter.get("/",(req,res)=>{
    UserService.list(req,res);
});

userRouter.get("/:id",(req,res)=>{
    UserService.get(req,res);
});

userRouter.post("/",(req,res)=>{
    UserService.create(req,res);
});


userRouter.delete("/:id",(req,res)=>{
    UserService.delete(req,res);
});

userRouter.patch("/:id",(req,res)=>{
    UserService.update(req,res);
});

export default userRouter;' > src/routes/user.route.js

mkdir src/services
#creates User Service
echo 'import User from "../models/user.model.js";

class UserService {
    list(req,res){
        User.find().then((data) => {
            res.send(data);
        });
    }

    get(req,res){
        User.findById(req.params.id).then((data)=>{
            res.send(data);
        })
    }

    create(req,res){
        User.create(req.body).then((data) =>{
            res.send(data);
        })
    }

    delete(req,res){
        User.findByIdAndDelete(req.params.id).then((data)=>{
            res.send("Deleted Successfully");
        })
    }

    update(req,res){
        User.findByIdAndUpdate(req.params.id,req.body).then((data)=>{
            res.send(data);
        })
    }
}

export default new UserService();' > src/services/user.service.js
# after this add start script in package.json and type module