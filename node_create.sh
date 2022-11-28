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
    logger.info("Server running on http://127.0.0.1:"+process.env.PORT);
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
import UserService from "../services/user.service.js"
const userRouter = new Router()
import verifyToken from "../middlewares/authJwt.middleware.js"

userRouter.get("/",verifyToken,(req,res)=>{
    UserService.list(req,res);
});

userRouter.get("/:id",verifyToken,(req,res)=>{
    UserService.get(req,res);
});

userRouter.delete("/:id",verifyToken,(req,res)=>{
    UserService.delete(req,res);
});

userRouter.patch("/:id",verifyToken,(req,res)=>{
    UserService.update(req,res);
});

export default userRouter;' > src/routes/user.route.js

mkdir src/services
#creates User Service
echo 'import User from "../models/user.model.js";
import bcrypt from "bcrypt"
import ResponseService from "./response.service.js";


class UserService {
    list(req,res){
        User.find().then((users) => {
            ResponseService.sendResult(res,users,"Users fetched Successfully!","success",200);
        }).catch(err =>{
            ResponseService.sendResult(res,null,err.message,"error",400);
        })
    }

    get(req,res){
        User.findById(req.params.id).then((user)=>{
            ResponseService.sendResult(res,user,"User fetched Successfully!","success",200);
        }).catch(err =>{
            ResponseService.sendResult(res,null,err.message,"error",400);
        })
    }

    delete(req,res){
        User.findByIdAndDelete(req.params.id).then((user)=>{
            ResponseService.sendResult(res,null,"User deleted successfully!","success",200);
        }).catch(err =>{
            ResponseService.sendResult(res,null,err.message,"error",400);
        })
    }

    update(req,res){
        User.findByIdAndUpdate(req.params.id,req.body).then((data)=>{
            User.findById(req.params.id).then(user =>{
                ResponseService.sendResult(res,user,"User updated successfully!","success",200);
            }).catch(err =>{
                ResponseService.sendResult(res,null,err.message,"error",400);   
            })
        }).catch(err =>{
            ResponseService.sendResult(res,null,err.message,"error",400);
        })
    }
}


export default new UserService();' > src/services/user.service.js


echo 'import {Router} from "express"
import AuthService from "../services/auth.service.js"
const authRouter = new Router();

authRouter.post("/login", (req,res)=>{
    AuthService.login(req,res)
})

authRouter.post("/register", (req,res)=>{
    AuthService.register(req,res)
})

export default authRouter;' > src/routes/auth.route.js

echo 'import User from "../models/user.model.js";
import bcrypt from "bcrypt"
import ResponseService from "./response.service.js";
import Jwt  from "jsonwebtoken";
class AuthService{
    login(req,res){
        User.findOne({email: req.body.email}).then(user=>{
            if(user){
                if(bcrypt.compareSync(req.body.password, user.password)){

                    Jwt.sign({
                        "useremail": user.email,
                        "username": user.name
                    }, process.env.JWT_SECRET,(err, token) =>{
                        ResponseService.sendResult(res,{"token":token },"LoggedIn Successfully","success",200);
                    });

                }else{
                    ResponseService.sendResult(res,[],"InValid User","error",400);
                }
            }else{
                ResponseService.sendResult(res,[],"No User User","error",404);
            }
        }).catch(err =>{
            ResponseService.sendResult(res,[],err.message,"error",404);
        })
    }

    register(req,res){
        req.body.password =  bcrypt.hashSync(req.body.password,10);
        User.create(req.body).then((user) =>{
            Jwt.sign({
                "useremail": user.email,
                "username": user.name
            }, process.env.JWT_SECRET,(err, token) =>{
                ResponseService.sendResult(res,{"token":token },"Registered Successfully","success",200);
            });
        }).catch(err =>{
            ResponseService.sendResult(res,null,err.message,"error",400);
        })
    }
}
export default new AuthService();' > src/services/auth.service.js

echo 'class ResponseService {
    sendResult(res,data,message,type,status){
        res.status(status).send({
            result: data ?? [],
            error: type == "error" ? message : null,
            message: type == "success" ? message : null,
            status: status
        })
    }
}

export default new ResponseService();' > src/services/response.service.js



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
import ResponseService from "../services/response.service.js";

const verifyToken = (req,res,next) => {
      Jwt.verify(req.headers.authorization ? req.headers.authorization.split(" ")[1] : "" ,process.env.JWT_SECRET,(err,result)=>{
            if(err){
              return  ResponseService.sendResult(res,[],"UnAuthorized","error",403)
            }
            return next()
        }) 
}

export default verifyToken;' > src/middlewares/authJwt.middleware.js


echo 'node_modules
.env
*.env' > .gitignore
# after this add start script in package.json and type module