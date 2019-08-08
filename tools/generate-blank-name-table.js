module.exports = {
  generateBlankNameTable: (fillBye = 0x00, byteCount = 960) =>
    Buffer.alloc(byteCount, fillBye)
};
