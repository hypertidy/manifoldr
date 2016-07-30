
topolclause <- function(x) {
  switch(x, 
         area = "IsArea([ID])", 
         line = "IsLine([ID])", 
         point = "IsPoint([ID])")
}
