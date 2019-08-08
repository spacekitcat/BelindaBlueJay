const fs = require('fs');
const { generateBlankNameTable } = require('./generate-blank-name-table');

let nameTableWriteStream = fs.createWriteStream('name-table-0.dat', { encoding: 'hex' });
nameTableWriteStream.write(generateBlankNameTable(0x00, 480));
nameTableWriteStream.close();

nameTableWriteStream = fs.createWriteStream('name-table-1.dat', { encoding: 'hex' });
nameTableWriteStream.write(generateBlankNameTable(0x00, 480));
nameTableWriteStream.close();
