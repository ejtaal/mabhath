#!/usr/bin/env perl

# s#A\^#آ#g;
# s#w\^#آ#g;
# s#y\^#آ#g;
# s#\^#''#g;
s#\^##g;
s#@#o#g;
s#<hi rend="ital" TEIform="hi">(.*?)</hi>#<i>$1</i>#gi;
s#<orth orig="" extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
s#<orth orig="" extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
s#<orth extent="full" lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
s#(<div2 n=")([^"]*?)(" type="root" org="uniform" sample="complete" part="N" TEIform="div2">)#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
s#(<div2 type="root" part="N" n=")([^"]*?)(" org="uniform")#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
s#(<entryFree id="n\d+" key=")([^"]*?)(" type="main">)#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
s#(<div1 part="N" n=")([^"]*?)(")#{ print $1; print encode "utf8", decode "buckwalter", $2; print $3; }#gei;
s#<foreign lang="ar" TEIform="foreign">(.*?)</foreign>#{ encode "utf8", decode "buckwalter", $1; }#gei;
s#<orth[^>]*? lang="ar">(.*?)</orth>#{ encode "utf8", decode "buckwalter", $1; }#gei;
# s#=#آ#g;
