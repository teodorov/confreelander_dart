grammar mutual_recursive;

s : 'b' e;
e :    #nothing
    | 'a' s #as
    ;
