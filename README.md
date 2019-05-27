# Belinda the Bluejay

A game written in 6502 assembly code for the Nintendo Entertainment System (NES). I'm at the start of this project and it currently initialises the NES (correctly, for my own purposes at least), sets up and loads basic graphics, defines some palettes and runs a basic render loop. The render loop handles controller input for all 8 directions (on a compass) and has code to select and configure an appropriate directional sprite. I've started learning 6502 assembly from scratch, so this is the definition of a "My First Assembly Language Program". I'm counting on making big mistakes because if I gain the wisdom to recognise them, I'll learn loads more.

I'm currently trying to figure out how to render the background. There are a different set of PPU ports for the background and sprites, the background drawing functionality is designed to support things like parallax scrolling (I didn't realise it was capable, I must have had bad taste in games as a kid), so there's a good bit more involved in getting it working.

## Assembling

You need to get the `ca65` assembler and make sure the executable is resolvable by your shell from your search path.  

```bash
 belinda-the-bluejay-6502-nes <master> % ./build.sh
```

## Running

You can just open the `rom.nes` file in a NES emulator, safest bet would be Nestopia (other ones might work, I've not tried). I wouldn't ordinarily add compiled binaries to a Git repo, but they're only 40KB and saves a lot of hassle.

## Resources

|URL|Content|Type|
|---|---|---|
|https://github.com/cc65/cc65/blob/master/cfg/nes.cfg|Ca65 configuration file for the NES, it documents the assembler sections and assumed address space setup specific to this platform.|Reference|
