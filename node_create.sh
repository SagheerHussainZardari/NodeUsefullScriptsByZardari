# RUN THIS FILE USING "chmod +x node_modules.sh" and than ./node_modules.sh projectName (project is name is optional here)

# make directory and cd into it
mkdir $1 && cd $1

# project and basic package installation
npm init -y && npm i express nodemon mongoose dotenv body-parser bcrypt jsonwebtoken winston

# creating env file
echo 'PORT=3000' > .env
echo 'DB_NAME=""' >> .env
echo 'DB_USER=""' >> .env
echo 'DB_PASSWORD=""' >> .env
echo 'MONGO_URI="mongodb://localhost:27017/node-practise-1"' >> .env
echo 'JWT_SECRET="test"' >> .env
mkdir src

# creating server file
echo 'import express from "express";
import dotenv from "dotenv";
import bodyParser from "body-parser";
import router from "./routes/index.route.js"
import connection from "./config/db.js";
import logger from "./logger.js";


const app = express();
dotenv.config();
connection();

app.use(bodyParser.json());

app.use(router);

app.listen(process.env.PORT || 3000, ()=>{
   logger.info("Server running on http://127.0.0.1:"+process.env.PORT+" started at: "+Date());
});' > src/server.js

echo 'import { createLogger , transports } from "winston";

const logger = createLogger({
    level: "debug",
    transports: [
        new transports.File({filename: "app.log"})
    ]
});

export default logger;' > src/logger.js


mkdir src/config

# creates connection file

echo 'import mongoose from "mongoose";

const connection = function(){
    mongoose.connect(process.env.MONGO_URI,{
    
    }).then(()=>{
        console.log("Connected to database successfully");
    }).catch((err)=>{
        console.log("Connection Failed ", err);
    });
}

export default connection;' > src/config/db.js


#make src/models
mkdir src/models
#creates User Model
echo 'import mongoose from "mongoose";
import  {Schema}  from "mongoose";

const userSchema = new Schema({
    name: String,
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    Date: {
        type: Date,
        default: Date.now
    }
});

const User = mongoose.model("user", userSchema);

export default User;' > src/models/user.model.js

mkdir src/routes
#create User Routes
echo 'import { Router } from "express";
import {list,get,destroy,update} from "../controllers/user.controller.js"
const userRouter = new Router()
import verifyToken from "../middlewares/authJwt.middleware.js"

userRouter.get("/",verifyToken,list);
userRouter.get("/:id",verifyToken,get);
userRouter.delete("/:id",verifyToken,destroy);
userRouter.patch("/:id",verifyToken,update);

export default userRouter;' > src/routes/user.route.js

mkdir src/controllers
#creates User Service
echo 'import User from "../models/user.model.js";
import bcrypt from "bcrypt"
import {sendResult} from "../helpers/utils.js";


const list = (req,res) =>{
    User.find().then((users) => {
        sendResult(res,users,"Users fetched Successfully!","success",200);
    }).catch(err =>{
        sendResult(res,null,err.message,"error",400);
    })
}

const get = (req,res) =>{
    User.findById(req.params.id).then((user)=>{
        if(user){
            sendResult(res,user,"User fetched Successfully!","success",200);
        }else{
            sendResult(res,[],"No User Found!","error",404);
        }
    }).catch(err =>{
        sendResult(res,null,err.message,"error",400);
    })
}

const destroy = (req,res) =>{
    User.findByIdAndDelete(req.params.id).then((user)=>{
        sendResult(res,null,"User deleted successfully!","success",200);
    }).catch(err =>{
        sendResult(res,null,err.message,"error",400);
    })
}

const update = (req,res) =>{
    User.findByIdAndUpdate(req.params.id,req.body).then((data)=>{
        User.findById(req.params.id).then(user =>{
            if(user){
                sendResult(res,user,"User updated successfully!","success",200);
            }else{
                sendResult(res,[],"No User Found!","error",404);
            }
        }).catch(err =>{
            sendResult(res,null,err.message,"error",400);   
        })
    }).catch(err =>{
        sendResult(res,null,err.message,"error",400);
    })
}


export  {list,get,destroy,update};' > src/controllers/user.controller.js


echo 'import {Router} from "express"
import {login, register}  from "../controllers/auth.controller.js"
const authRouter = new Router();

authRouter.post("/login", login)
authRouter.post("/register", register)

export default authRouter;' > src/routes/auth.route.js

echo 'import User from "../models/user.model.js";
import bcrypt from "bcrypt"
import {sendResult} from "../helpers/utils.js";
import Jwt  from "jsonwebtoken";

const login = (req,res) =>{
    User.findOne({email: req.body.email}).then(user=>{
        if(user){
            if(bcrypt.compareSync(req.body.password, user.password)){

                Jwt.sign({
                    "useremail": user.email,
                    "username": user.name
                }, process.env.JWT_SECRET,{expiresIn: "20s"},(err, token) =>{
                    sendResult(res,{"token":token,"expiresIn": "20 seconds" },"LoggedIn Successfully","success",200);
                });

            }else{
                sendResult(res,[],"InValid User","error",400);
            }
        }else{
            sendResult(res,[],"No User User","error",404);
        }
    }).catch(err =>{
        sendResult(res,[],err.message,"error",404);
    })
}

const register = (req, res) =>{
    req.body.password =  bcrypt.hashSync(req.body.password,10);
    User.create(req.body).then((user) =>{
        Jwt.sign({
            "useremail": user.email,
            "username": user.name
        }, process.env.JWT_SECRET,{expiresIn: "20s"},(err, token) =>{
            sendResult(res,{"token":token,"expiresIn": "20 seconds" },"Registered Successfully","success",200);
        });
    }).catch(err =>{
        sendResult(res,null,err.message,"error",400);
    })
}

export  {login, register}' > src/controllers/auth.controller.js

echo 'import {Router} from "express"
import userRouter from "./user.route.js";
import authRouter from "./auth.route.js";

const router = new Router();

router.use("/users",userRouter);
router.use("/auth",authRouter);

router.get("*",(req,res) =>{
    res.send("404");
});

export default router;' > src/routes/index.route.js

mkdir src/middlewares


echo 'import Jwt from "jsonwebtoken";
import logger from "../logger.js";
import {sendResult} from "../helpers/utils.js";
const verifyToken = (req,res,next) => {
      Jwt.verify(req.headers.authorization ? req.headers.authorization.split(" ")[1] : "",process.env.JWT_SECRET,(err,result)=>{
            if(err){
                logger.error("Token InValid: "+req.headers.authorization.split(" ")[1])
                return  sendResult(res,[],"UnAuthorized","error",403)
            }

            req.userId = result.id;
            logger.info("Token valid",result)
            return next()
        }) 
}

export default verifyToken;' > src/middlewares/authJwt.middleware.js


echo 'node_modules
.env
*.env' > .gitignore


mkdir src/helpers

echo 'export const sendResult = (res,data,message,type,status) =>{
    res.status(status).send({
        data: data ?? [],
        type: type,
        message: message,
        status: status
    })
}' > src/helpers/utils.js
# after this add start script in package.json and type module