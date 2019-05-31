const { generateBlankNameTable } = require('./generate-blank-name-table');

describe('The `generateBlankNameTable` module', () => {
  describe('No arguments are specified', () => {
    it('should generate 64 bytes for the name table', () => {
      expect(generateBlankNameTable().length).toBe(960);
    });

    it('should generate the expected byte pattern for the entire contents of the name table', () => {
      generateBlankNameTable().forEach(byte => {
        expect(byte).toBe(0b00000000);
      });
    });
  });

  describe('Custom arguments are specified for the byteCount and fillByte', () => {
    const specifiedByteCount = 1024;
    const specifiedFillBye = 0x42;

    it('should generate 64 bytes for the name table', () => {
      expect(
        generateBlankNameTable(specifiedFillBye, specifiedByteCount).length
      ).toBe(specifiedByteCount);
    });

    it('should generate the expected byte pattern for the entire contents of the name table', () => {
      generateBlankNameTable(
        specifiedFillBye,
        specifiedByteCount
      ).forEach(byte => {
        expect(byte).toBe(specifiedFillBye);
      });
    });
  });
});
