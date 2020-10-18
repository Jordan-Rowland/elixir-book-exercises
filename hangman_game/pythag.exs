result = for a <- 1..99, b <- a + 1..99, c <- 1..99, a*a + b*b == c*c, do: {a,b,c}
