# Belinda the Bluejay

A game written in 6502 assembly code for the Nintendo Entertainment System (NES). I'm at the start of this project and it currently initialises the NES (correctly, for my own purposes at least), sets up and loads basic graphics, defines some palettes and runs a basic render loop. The render loop handles controller input for all 8 directions (on a compass) and has code to select and configure an appropriate directional sprite. I've started learning 6502 assembly from scratch, so this is the definition of a "My First Assembly Language Program". I'm counting on making big mistakes because if I gain the wisdom to recognise them, I'll learn loads more.

I'm currently thinking about what to do next, trying to improve the existing code and trying to make some better sprites.

## Assembling

You need to get the `ca65` assembler and make sure the executable is resolvable by your shell from your search path.  

```bash
 belinda-the-bluejay-6502-nes <master> % ./build.sh
```
