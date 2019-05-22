# Belinda the Bluejay

A game written in 6502 assembly code for the Nintendo Entertainment System (NES). I've just started this project and it currently initialises the NES (correctly, for my own purposes at least), sets up and loads basic graphics, defines some palettes and runs a basic render loop which draws the first sprite sheet slice. I've started learning 6502 assembly from scratch, so this is the definition of a "My First Assembly Language". I'm counting on making big mistakes because if I gain the wisdom to recognise them, I'll learn loads more.

I'm currently working on adding the first go at a control system.

## Assembling

You need to get the `ca65` assembler and make sure the executable is resolvable by your shell from your search path.  

```bash
 belinda-the-bluejay-6502-nes <master> % ./build.sh
```
