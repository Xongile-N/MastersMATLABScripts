%prepare lookup tables for modulo operations (to save runtime)

switch(base)
    case(2)
        LookUp = [0, 0; 2, 1];
    case(3)
        LookUp = [0, 0, 0; 3, 1, 2; 3, 2, 1];
    case(5)
        LookUp = [0, 0, 0, 0, 0; 5, 1, 2, 3, 4; 5, 3, 1, 4, 2; 5, 2, 4, 1, 3; 5, 4, 3, 2, 1];
    case(7)
        LookUp = [0, 0, 0, 0, 0, 0, 0; 7, 1, 2, 3, 4, 5, 6; 7, 4, 1, 5, 2, 6, 3; 7, 5, 3, 1, 6, 4, 2; ...
            7, 2, 4, 6, 1, 3, 5; 7, 3, 6, 2, 5, 1, 4; 7, 6, 5, 4, 3, 2, 1];
end

