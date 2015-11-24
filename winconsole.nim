#
#    Windows Console
#

const GENERIC_READ : culong = (culong) 0x80000000
const GENERIC_WRITE : culong = 0x40000000
const FILE_SHARE_READ : culong = 0x00000001
const CONSOLE_TEXTMODE_BUFFER : culong = 1

const WIN32_NULL : int = 0

type
  BOOL   = int
  HANDLE* = int

  COORD* = object
    x*: cshort
    y*: cshort

  SMALL_RECT* = object
    Left*: cshort
    Top*: cshort
    Right*: cshort
    Bottom*: cshort

proc GetConsoleWindow*() : HANDLE
  {. stdcall, importc: "GetConsoleWindow", dynlib: "Kernel32.dll" .}

proc SetConsoleScreenBufferSize( hCon: HANDLE, coord: COORD )
  {. stdcall, importc: "SetConsoleScreenBufferSize", dynlib: "Kernel32.dll" .}

proc SetConsoleWindowInfo( hConsoleOutput: HANDLE, bAbsolute: BOOL,
  lpConsoleWindow: ptr SMALL_RECT )
    {. stdcall, importc: "SetConsoleWindowInfo", dynlib: "Kernel32.dll" .}

proc CreateConsoleScreenBuffer( desiredAccess: culong, shareMode: culong,
  secAttr: int, flag: culong, reserved: int ) : HANDLE
    {. stdcall, importc: "CreateConsoleScreenBuffer", dynlib: "Kernel32.dll" .}

proc SetConsoleActiveScreenBuffer*( hConsoleOutput: HANDLE ): BOOL
  {. stdcall, importc: "SetConsoleActiveScreenBuffer", dynlib: "Kernel32.dll" .}

proc FillConsoleOutputCharacter( hConsoleOutput: HANDLE, cCharacter: Utf16Char,
  nLength: culong, dwWriteCoord: COORD, lpNumOfCharsWritten: ptr culong )
    {. stdcall, importc: "FillConsoleOutputCharacterW", dynlib: "Kernel32.dll" .}

proc SetConsoleTitle( title: WideCString ): BOOL
  {. stdcall, importc: "SetConsoleTitleW", dynlib: "Kernel32.dll" .}
proc SetConsoleTitle*( title: string ): BOOL =
  let wideTitle = newWideCString( title )
  return SetConsoleTitle( wideTitle )

proc SetConsoleSize*( hConsole: HANDLE, width: int16, height: int16 ) =
  var
    c : COORD
    r : SMALL_RECT

  c.x = width
  c.y = height

  r.Left = 0
  r.Top = 0
  r.Right = (width-1)
  r.Bottom = (height-1)

  SetConsoleScreenBufferSize( hConsole, c )
  SetConsoleWindowInfo( hConsole, 1, addr(r) )

proc SetCharAt*( hConsole: HANDLE, x: int, y: int, c: char ) =
  var
    numOfWritten: culong
    wp : COORD
  wp.x = (cshort) x
  wp.y = (cshort) y
  FillConsoleOutputCharacter( hConsole, Utf16Char(c),
    1, wp, addr(numOfWritten) )

proc WriteAt*( hConsole: HANDLE, x: int, y: int, text: string ) =
  var count : int = 0

  for ch in text:
    SetCharAt( hConsole, (x+count), y, ch )
    count += 1

proc CreateConsoleScreenBuffer * () : HANDLE =
  return CreateConsoleScreenBuffer( GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ,
    WIN32_NULL,
    CONSOLE_TEXTMODE_BUFFER,
    WIN32_NULL )

when isMainModule:
  let con = CreateConsoleScreenBuffer()

  discard SetConsoleTitle( "Console Example" )
  discard SetConsoleActiveScreenBuffer( con )
  SetConsoleSize( con, 20, 20 )
