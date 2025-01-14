const http= require('node:http')

const server=http.createServer()

server.on('request', (req,res)=>{
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        data: 'Hellll yeaaaaah!!!!!',
    }));
})

server.listen(3000,()=>{
    console.log("server is listening on http://localhost:3000")
})

// When this dir is mounted on a container,to restart the server on file change, we use the `-L` flag with nodemon. Check package.json. 