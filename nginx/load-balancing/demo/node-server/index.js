const app=require('express')();
const os=require('node:os')

app.get('/',(req,res)=>{
    res.status(200).json({msg:"success!!",host:os.hostname()});
})

app.listen(3000,()=>{
    console.log("server is listening on port 3000");
})
