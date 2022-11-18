mkdir src

#make src/models
mkdir src/models
#creates User Model

echo 'import mongoose from "mongoose";
import  {Schema}  from "mongoose";

const '$1'Schema = new Schema({
    name: String
});

const '$1' = mongoose.model('\'$1\'', '$1'Schema);

export default '$1';' > src/models/$1.model.js
