#
#       Conway's Game of Life
#

import winconsole
import os

const FIELD_WIDTH  : int = 30
const FIELD_HEIGHT : int = 20
const FIELD_SIZE   : int = FIELD_WIDTH * FIELD_HEIGHT - 1

type
  GameField = ref GameFieldObj
  GameFieldObj = array[0..FIELD_SIZE, bool]

proc makeField() : GameField =
  var field : GameField
  new( field )

  for i in 0..FIELD_SIZE:
    field[i] = false

  return field

proc copyField( src: GameField, dst: GameField ) =
  for i in 0..FIELD_SIZE:
    dst[][i] = src[][i]

proc loadFieldFromFile( file: string, field: GameField ) =
  var count: int = 0
  var f = open( file )
  for line in f.lines:
    for c in line:
      if c == '1':
        field[count] = true
      count += 1
      if count >= field[].len:
        break
  f.close

proc inside( index: int ) : bool =
  return (index > -1) and (index < FIELD_SIZE)

proc isAlive( index: int, field: GameField ) : bool =
  var count : int = 0
  if inside(index-1) and field[index-1]:
    count += 1
  if inside(index+1) and field[index+1]:
    count += 1

  for a in (index-FIELD_WIDTH-1)..(index-FIELD_WIDTH+1):
    if inside(a) and field[a]:
      count += 1

  for b in (index+FIELD_WIDTH-1)..(index+FIELD_WIDTH+1):
    if inside(b) and field[b]:
      count += 1

  if count == 3:
    return true

  if field[index] and count == 2:
    return true

  return false


proc updateField( field: GameField ) =
  var buffer: GameField
  new( buffer )

  for i in 0..FIELD_SIZE:
    buffer[i] = isAlive( i, field )

  copyField( buffer, field )

proc drawField( console: winconsole.HANDLE, generation: int, field: GameField ) =
  const LIVE = '#'
  const DEAD = ' '

  var generationText = "Generation: " & $generation
  winconsole.WriteAt( console, 0, 0, generationText )

  var x, y: int
  x = 0
  y = 1

  for i in 0..FIELD_SIZE:
    var c = if field[i]: LIVE
      else: DEAD
    winconsole.SetCharAt( console, x, y, c )
    x += 1

    if x >= FIELD_WIDTH:
      y += 1
      x = 0


#### MAIN ####
when isMainModule:
  let field: GameField = makeField()
  var generation: int = 0

  # prepare windows console
  let con = winconsole.CreateConsoleScreenBuffer()

  discard winconsole.SetConsoleTitle( "Conway's Game of Life - ACORN" )
  discard winconsole.SetConsoleActiveScreenBuffer( con )
  winconsole.SetConsoleSize( con, toU16(FIELD_WIDTH), toU16(FIELD_HEIGHT+1) )

  loadFieldFromFile( "acorn.txt", field )

  while true:
    drawField( con, generation, field )
    updateField( field )
    generation += 1
    sleep( 3000 )
