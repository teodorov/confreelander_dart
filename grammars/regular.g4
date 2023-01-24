grammar regular;

//x0
//    :       #Nothing0
//    | 'a'   #as0
//    | x0    #xs0
//    ;

p : p p
    | '[' p ']'
    | '[' ']'
    ;

q :   '[' ']'
    | '[' q ']'
    | q q
    ;

x1 :         #Nothing
    | 'a' x1 #As
    ;



x3: X3;
X3 : 'a'*;

x2 : X2;
X2 : | 'a' X2;

xs
    : 'a'*
    ;

WS : [ \r\t\n]+ -> skip ;