module.exports = {
  generateBlankNameTable: (fillBye = 0x00, byteCount = 64) =>
    Buffer.alloc(byteCount, fillBye)
};
