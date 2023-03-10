grammar json;
json 
	: 'null'
	| 'true'
	| 'false'
	| string
	| number
	| object
	| array
	;
string
	: '"' character* '"'
	;
number
	: integer '.'? (('E' | 'e') ('+'|'-')? ('0' .. '9')+)?
	;
object
	: '{' string ':' json '}'
	;
array
	: '[' (json (',' json)+)* ']'
	;
character
	: ~('\u0000' .. '\u001F' | '"' | '\\') // [0020 .. 10FFFF] & ~('"' | '\\')
	| '\\' escaped
	;
escaped
	: ["\\/bfnrt]
	| 'u' hex hex hex hex
	;
hex
	: '0' .. '9'
	| 'A' .. 'F'
	| 'a' .. 'f'
	;
integer
	: '-'? ('0' | '1'..'9' '0' .. '9')
	;

WS
   : [ \t\n\r]+ -> skip
   ;