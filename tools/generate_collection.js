const fs = require('fs/promises')
const path = require('path')

async function main(dataDir, contentType) {
    const files = await fs.readdir(dataDir);
    const sortedFiles = files.sort();
    const hashes = sortedFiles.map(f => toHash(path.join(dataDir, f), contentType))

}

async function toHash(filePath, contentType) {
    const { size } = await fs.stat(filePath)
    const header = Buffer.from([]);
    const content = await fs.readFile(filePath)

}