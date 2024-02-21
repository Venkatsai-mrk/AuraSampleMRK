const fs = require('fs');
const readline = require('readline')

async function extractTests(){
    let testsFile = __dirname+'/testsToRun.txt';
    await fs.promises.writeFile(testsFile,'all');

    const lines = readline.createInterface({
        input: fs.createReadStream(__dirname+'/pr_body.txt'),
        crlfDelay: Infinity
    });

    for await (const line of lines) {
        if(line.includes('Name[') && line.includes(']Name')){

            let tests = line.substring(5,line.length-5);
            await fs.promises.writeFile(testsFile,tests);
            await fs.promises.appendFile(testsFile,'\n');
        }
    }
}

extractTests();