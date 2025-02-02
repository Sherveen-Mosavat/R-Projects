library(foreign)
install.packages("stargazer")
library(stargazer)

wage1 <- read.dta("http://fmwww.bc.edu/ec-p/data/wooldridge/wage1.dta")

#show me first few rows
head(wage1)

##to pick a variable in a dataset first type dataset then $ and then the variable
mean(wage1$wage)
sd(wage1$wage)

#summary statistics table of variable wage
summary (wage1$wage)
subset(wage1,select=c(wage))
stargazer(subset(wage1,select=c(wage)), type='text')
stargazer(subset(wage1,select=c(wage,exper,tenure)), type='text')
stargazer(subset(wage1,female==1,select=c(wage)), type='html', out="womenstats.html")

#look at all the levels of education
table(wage1$educ)

#t-test checking the mean of the variable
t.test(wage1$wage-6)
