# Learning Nim

This repo contains odd bits and pieces as I'm trying to learn Nim. The code is probably not well optimized or written in a "Nim" way, but it's a start!

The `tutorial/` folder contains some bits and pieces that I've pulled from various tutorials and played with.

The `maze-solver/` folder contains code for [Trémaux's Algorithm](https://en.wikipedia.org/wiki/Maze-solving_algorithm#Tr%C3%A9maux's_algorithm), used to solve mazes. It's been ported from my previous JavaScript implementation just to start writing some Nim code.

> TODO: I'd like to use Nim's `js` build target to generate a file that draws the maze and its solution on a canvas.

The `jester/` folder contains a super basic CRUD API (currently, all in memory) written using, you guessed it, [jester](https://github.com/dom96/jester). Also includes my thoughts on the framework.

> TODO: Use [norm](https://github.com/moigagoo/norm) to make it a "proper" CRUD API.

## Running the code

For all of the `.nim` files you see, just run:

```shell
❯ nim c -r [filename].nim
```
