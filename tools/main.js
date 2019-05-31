const fs = require('fs');
const { generateBlankNameTable } = require('./generate-blank-name-table');

const nameTableWriteStream = fs.createWriteStream('name-table.dat', { encoding: 'hex' });
nameTableWriteStream.write(generateBlankNameTable(0x24));
nameTableWriteStream.close();
