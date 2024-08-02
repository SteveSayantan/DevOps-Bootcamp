/*
    ------------ 
    Create a JS Code to get a list of the running EC2 instances
    ------------

    Ref: https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/
*/

require('dotenv').config();
const { EC2Client, DescribeInstancesCommand }=require( "@aws-sdk/client-ec2")

async function getInfo(){
    const client= new EC2Client()
    const input = {
        MaxResults: Number("6"),
    };
    const command = new DescribeInstancesCommand(input);

    try {            
        const response = await client.send(command);
        console.log(response);
    } catch (error) {
        console.log(error);
    }
}

getInfo();