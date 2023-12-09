const fs = require("fs/promises");
const path = require("path");
const { keccak256 } = require("viem");
const mt = require("@openzeppelin/merkle-tree");

async function generate(dataDir, contentType) {
  const files = await fs.readdir(dataDir);
  const sortedFiles = files.sort();
  const hashes = await Promise.all(
    sortedFiles.map(async (f) => {
      const { hash } = await envelope(path.join(dataDir, f), contentType);
      return [hash];
    })
  );

  const tree = mt.StandardMerkleTree.of(hashes, ["bytes32"]);
  await fs.writeFile("tree.json", JSON.stringify(tree.dump()));
}

function pushData(data) {
  const size = data.length;

  if (size < 76) {
    return Buffer.concat([Buffer.from([size]), data]);
  }
  if (size < 255) {
    return Buffer.concat([Buffer.from([0x4c, size]), data]);
  }
  if (size < 255 * 255) {
    const buf = Buffer.alloc(2);
    buf.writeInt16LE(size);
    return Buffer.concat([Buffer.from([0x4d]), buf, data]);
  }
  const buf = Buffer.alloc(4);
  buf.writeUInt64LE(size);
  return Buffer.concat([Buffer.from([0x4e]), buf, data]);
}

async function envelope(filePath, contentType) {
  //@TODO length of content type <= 255
  const contentTypeBuf = Buffer.from(contentType, "utf8");
  const buf = await fs.readFile(filePath);
  const data = Buffer.concat([
    Buffer.from([0x0, 0x63]),
    pushData(Buffer.from([0x6f, 0x72, 0x64])),
    pushData(Buffer.from([0x1])),
    pushData(contentTypeBuf),
    pushData(Buffer.from([0x0])),
    pushData(buf),
    Buffer.from([0x68]),
  ]);
  const hash = keccak256(data);
  return { data, hash };
}
exports.generate = generate;
exports.envelope = envelope;
