import re

r'^abc[ab]+\s\t\d'
% 'abca \t1'
r'^\d{1,2}\/\d{1,2}\/\d{4}$'
% '11/12/2004'
r'\s*[a-zA-Z,\s]+\s*'
% ' aBz '
