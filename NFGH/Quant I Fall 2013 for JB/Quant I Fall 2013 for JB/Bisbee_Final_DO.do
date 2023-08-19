clear all
set more off

global filepath "C:\Users\j\Desktop\Player Hater\Fall 2013\Quant 1\"
capture log close
cd "$filepath"
log using "Bisbee_Final_LOG.txt",replace

use annenberg2004.dta

* 1: Run the command that lists the names of variables, their formats and labels.
describe

*2_a: What is the mode of bush-favorability?
tab bush_favorability
* ANSWER: The most frequent response is 0 or "very unfavorable". Poor Bush.

*2_b: What is its mean?
sum bush_favorability
* ANSWER: The mean is 7.525043. However, this data needs to be recoded since there are huge
* outliers that we're not interested in. Ignoring these values yields 5.282474 as the mean.
tab bush_favorability, nolabel
sum bush_favorability if bush_favorability <= 10

*2_c: What is the 95% confidence interval about this mean?
reg bush_favorability if bush_favorability <= 10
sum bush_favorability if bush_favorability <=10
local df = r(N)-1
di "lower bound: " r(mean) - (-invttail(`df',0.025))*(r(sd) / sqrt(r(N)))
di "upper bound: " r(mean) + (invttail(`df',0.975))*(r(sd) / sqrt(r(N)))
* ANSWER: This CI increases to 
* ANSWER: I chose this approach just for funsies. It gives the regression of the variable of interest
* on only a constant, meaning the information simply reproduces the mean but also includes the 95% CI. 
* In this case, the CI is between 5.19053 and 5.374418. 

* 2_d: What is the 90% confidence interval about this mean?
sum bush_favorability if bush_favorability <=10
local df = r(N)-1
di "lower bound: " r(mean) - (-invttail(`df',0.05))*(r(sd) / sqrt(r(N)))
di "upper bound: " r(mean) + (invttail(`df',0.95))*(r(sd) / sqrt(r(N)))
* ANSWER: This CI decreases to 5.2053161 and 5.3596324.

* 2_e: Who rates Bush more favorably, men or women?
*_i Answer this question with a t-test.
ttest bush_favorability if bush_favorability <= 10, by(female)
* ANSWER: Men rate Bush more favorably than women with a difference of 0.368 points that is highly significant.
*_ii Answer this question with a bivariate regression.
reg bush_favorability female if bush_favorability <= 10
* ANSWER: Same outcome except (since female is coded == 1), the coefficient is -0.368. This means that women rate
* Bush 0.368 points less favorably than men on average (and not controlling for anything). 

* 2_f: Are higher income Americans more likely to assess Bush favorably than lower income Americans?
* _i Examine how income should enter into the model as a predictor.
sum income
sort income
tab income
tab income, nolabel
gen increc = .
replace increc = 5 if income == 1
replace increc = 12.5 if income == 2
replace increc = 20 if income == 3
replace increc = 30 if income == 4
replace increc = 42.5 if income == 5
replace increc = 62.5 if income == 6
replace increc = 87.5 if income == 7
replace increc = 125 if income == 8
replace increc = 175 if income == 9
label var increc "Income"
* ANSWER: I decided to recode income as the mean value between the bounds for each bin. This was necessary because, 
* without doing so, the unit change from $10K to $15K would have been the same magnitude as the unit change from 
* $100K to $125K despite the fact the absolute value difference in the first case is $5K and in the second is five 
* times this size. I also divided these results by 1000 in order to make the coefficient of interest easier to read 
* and interpret. (Otherwise, it would have been a TINY ASSED NUMBER.
* _ii Interpret your results.
reg bush_favorability increc if bush_favorability <=10
* ANSWER: This result suggests that income is positively related to support for Bush to the tune of roughly 0.0041 
* additional points in favorability ratings associated with an additional $1,000 in pre-tax income. If I had more time,
* I would do a bunch of different things to this analysis including adding controls and curvelinear specifications. But
* let us not talk falsely now, the hour is getting late.

* 3_a: Run a regression of rating_diff on the variables age, female, and income. We'll call this model I.
sort kerry_favorability
tab kerry_favorability, nolabel
gen rating_diff = .
replace rating_diff = bush_favorability - kerry_favorability if bush_favorability <= 10 & kerry_favorability <= 10
reg rating_diff age female increc

* 3_b: How well does Model I explain variation in the dependent variable?
* ANSWER: Not very well. The R-squared statistic is only 0.0115, meaning we're only explaining roughly 1.2% of the
* variation in the dependent variable with this specification. Furthermore, the root MSE is quite high, suggesting that 
* the typical estimated value for the rating_diff observations is about 5.7 units away. Given that we're looking at a 
* range of values between -10 and 10, this is not reassuring for this model.

* 3_c: Now run the same regression but add the ideology variable. Call this Model II.
* _i In a few sentences, explain what happens to the coefficient on female between Model I and Model II and your
* substantive interpretation of this change.
tab ideology
tab ideology, nolabel
reg rating_diff age female increc ideology if ideology <= 5
* ANSWER: This model is a lot better. The R-squared has greatly improved and the root MSE has fallen dramatically. 
* The coefficient on female specifically has moved from -0.8639639 to -0.6182672. This suggests that ideology is a 
* confounding variable whose omission biases the ceteris paribus relationship between females and the difference 
* between support for Bush and Kerry. Specifically, the OVB created on the female coefficient by not controlling for
* ideology exacerbated the relationship by making it more negative that it truly is. This implies that there is non-zero
* covariance between females and ideology as well as non-zero covariance between ideology and the difference in support
* for Bush and Kerry. 

* _ii How well does Model II explain variation in the dependent variable compared to Model I?
* ANSWER: Although I've already touched on this above, the R-squared has increased substantially, suggesting the addition
* of ideology as a control variable increased our model's explanatory power from 1.2% of the variation in rating_diff to 
* roughly 22%. Commensurate to this improvement, the root MSE measurement has fallen from 5.7 units to roughly 5, 
* representing almost a full unit of support.

* _iii What does Model II predict is the different in rating_diff between those who are very conservative and those
* who are very liberal, holding the other factors constant? Approximately, what percentage of the range of the dependent
* variable is this difference equal to?
di -2.66*(5-1)
* ANSWER: I could do some fanciness with STATA 12's new margins and contrast commands but I'll do it the old fashioned way
* for now. Assuming a linear relationship between the dependent variable and ideology, I can just multiply the coefficient
* by the total number of units separating very liberal from very conservative. In this case, it would be -2.66*(5-1) = -10.64.
* This means that the difference between support for Bush and the support for Kerry drops by 10.5 points between the most 
* liberal and most conservative respondants in the sample. This is equivalent to roughly 50% of the range of the dependent
* variable.

* _iv What do your answers to (ii) and (iii) suggest about the importance of ideology in explaining the dependent variable
* compared to the other variables in Model II?
* ANSWER: From (ii), it is clear that ideology is doing the lion's share of the work in explaining variation in the
* dependent variable relative to the other explanatory variables. This is seen in the dramatic increase in the R-squared 
* measurement. From (iii), this same concept is reflected in the range of variation in the dependent variable captured
* in the extremes of the ideology explanatory variable. Since the root MSE is simply the square root of the SSR divided by
* the square root of the total number of observations, the fact that the ideology variable's range covers roughly 50% of 
* the total possible range of the dependent variable suggests it is an important explanatory variable. 

* 3_d: Finally, run the estimation in a way that does not require that we assume ideology is an interval-level variable. 
* Call this equation Model III
reg rating_diff age female increc i.ideology if ideology <= 5
* Alternatively:
margins ideology

* _i What would we need to see in Model III that would give us confidence in treating ideology as an interval-level
* variable in the present context? Do we see this here?
* ANSWER: From the first regression in which we just dummied out the 5 levels of ideology, we would want to see roughly 
* similar intervals between each coefficient (if we're assuming the relationship is linear). Clearly, this is not the case
* in the first example since the difference between very conservative and conservative is only -0.76 while the difference
* between conservative and moderate is -4.63. Similarly on the high end, the difference between liberal and very liberal 
* is a small -1.6 while the difference between liberal and moderate is a much larger -2.5 units. This conclusion is also 
* reflected in the follow up margins command which gives the ceteris paribus means associated with each level of ideology. 
* In conclusion, we don't see evidence in support of treating ideology as an interval level variable in these analyses. 
* (HOWEVER, an argument could be made for a polynomial fit to the data that allows for curvelinear relationships between
* the dependent variable and ideology when measured at the interval level. 

* _ii In a few sentences, say what Model III tells us about the ceteris paribus relationship between ideology and rating_diff.
* ANSWER: Goddamn...I always jump the gun on these questions! Ah well...Model III tells us that, controlling for age, gender
* and income (if we want to make the assumption that controlling for just these gives us a ceteris paribus understanding of
* ideology, then I've got some snake oil to sell you), ideology has a statistically significant negative relationship with 
* our dependent variable. Meaning, the more liberal the respondant self-reports, the less favorable toward Bush he / she is
* relative to their feelings on Kerry. Even more specifically, we can say that very conservative respondents support Bush
* more than Kerry by almost 4 favorability points, holding age, gender, and income constant. Meanwhile very liberal 
* respondants support Kerry over Bush by almost 5 favorability points, again assuming our controls give us the ceteris
* paribus relationship. 

* 3_e: Create a table displaying the estimates from Models I, II, and III. 
* Model I:
reg rating_diff age female increc
eststo I
reg rating_diff age female increc ideology if ideology <= 5
eststo II
reg rating_diff age female increc i.ideology if ideology <= 5
eststo III
esttab I II III using table1.tex, cells(b(star fmt(3)) se(par fmt(3))) stats(N, labels(N) fmt(0)) starlevel(+ .10 * .05 ** .01 *** .001) replace tex nolz label noabb wrap varwidth(50) mtitles
* ANSWER: I asked Andrew whether we need to show this table in our log file somehow but he said no, it's only for Latex. So
* please run the above code and then copy the output into Latex to see the beauty I hath wrought.

* 4 Is the ceteris paribus association between a voter's personal economic situation and rating_diff stronger for Independent
* voters than for those who are strongly affiliated with either the Democratic or Republican parties?

* Step 1: Checking out the variables I'm interested in:
sum pid
tab pid
tab pid, nolabel
clonevar pidrec = pid
replace pidrec = . if pid > 5
replace pidrec = 3 if pid == 4
sum pidrec pid
tab pidrec pid, mi

sum economic_situation
tab economic_situation
tab economic_situation, nolabel
clonevar ecsit = economic_situation
replace ecsit = . if economic_situation > 5
sum ecsit economic_situation
tab ecsit economic_situation, mi

clonevar ideorec = ideology
replace ideorec = . if ideology >6
sum ideorec ideology
tab ideorec ideology, mi
* ANSWER (to my own question, I guess...): I've relabeled these variables as necessary and ensured that I didn't make any
* mistakes in doing so. I also conflated independents with 'something else' because, honestly, who are they kidding?

* Step 2: Eyeball Metrics Baby!
grmeanby female ecsit pidrec ideorec, summarize(rating_diff)

* ANSWER: According to this, there's not a huge impact of being independent on whether they prefer Bush or Kerry more (this
* conclusion stands to such reason one could call it almost tautological). Interestingly, there does appear to be a monotonic
* relationship between one's self-reported economic situation and the difference rating in which the worse off economic 
* an individual perceives themself to be, the more favorable they are toward Kerry. The inverse relationship holds for 
* favorability toward Bush. 

* Getting more sophisticated...dummying out the variables:
reg rating_diff i.pidrec i.ecsit i.ideorec age increc female
eststo I
* ANALYSIS: As expected, as we move away from the most conservative-friendly situations (the wealthiest, most ideology 
* conservative, and strongest self-identified Republicans), we see declines in favorability of Bush over Kerry. Interestingly,
* income is now negatively associated with support for Bush although it is not highly significant (p-value = 0.064). Even more
* relevant to this analysis, it appears that independents are way less favorable toward Bush (relative to Republicans) than 
* Demoratics are, controlling for everything else. 

* Adding polynomials and interaction terms:
gen femXage = female*age
gen age2 = age^2
gen increc2 = increc^2
reg rating_diff i.pidrec i.ecsit i.ideorec age age2 increc increc2 female femXage
eststo II
* ANALYSIS: Getting more and more interesting results here. Age is significant again and finds that there is a bell shape to
* the support for Bush (or a U-shape for the support of Kerry). Similarly, while females prefer Kerry on average, they are 
* more supportive of Bush as they get older. Income no longer appears to be significant after controlling for these other 
* variables. But we're still ignoring the core question (I do like mucking around in data sets before getting down to brass
* tacks.)

* Alright...to answer the question: are independents' judgements of Bush and Kerry more susceptible to their economic 
* situation than partisans? First just looking at the simplest relationship:
gen ind = .
replace ind = 0 if pidrec == 1 | pidrec== 3
replace ind = 1 if pidrec == 2
gen indXecsit = ind*ecsit
reg rating_diff ecsit ind indXecsit
eststo III
* ANALYSIS: Ho ho! It appears that, while being an independent makes you less favorable toward Bush, and being relatively 
* worse off economically makes you less favorable toward Bush, being an Independent and being worse off economically makes
* you MORE favorable toward Bush!

* Now adding a battery of controls...
reg rating_diff ecsit ind indXecsit age age2 increc female femXage
eststo IV
* ANALYSIS: This conclusion is robust to the inclusion of controls.

* Okay...finally getting to the best stuff...
reg rating_diff i.ecsit i.pidrec#i.ecsit age age2 increc female femXage

* should be:
reg rating_diff i.pidrec##i.ecsit age age2 increc female femXage

eststo V

* ANALYSIS: This appears to confirm the finding that, contrary to the hypothesized relationship, the ceteris paribus 
* relationship between a voter's personal economic situation and their views on the candidates is weaker for independents
* than partisans. This is expressed in the comparison of the coefficients on the dummied out economic situations and the 
* effect of these economic situations when interacted with the party id codes. Simply put, Independents (party id = 3) are
* less strong than democrats in preferring Kerry to Bush at lower levels of self-reported economic well-being. Specifically,
* independents who rated their economic situation as 'poor' only favor Kerry to Bush by 4 points compared to Democrats with 7
* points. Indeed, independents are not much more relatively favorable to Kerry than Republicans who self-reported their 
* economic situation as 'poor' (3.44 more favorability points toward Kerry compared to 4.09 favorability points). It is worth
* noting, however, that the brunt of our data for the self-reported economic conditions is clustered in the middle with 
* relatively few observations reporting either 'excellent' or 'poor'. 

esttab I II III IV using table2.tex, cells(b(star fmt(3)) se(par fmt(3))) stats(N, labels(N) fmt(0)) starlevel(+ .10 * .05 ** .01 *** .001) replace tex nolz label noabb wrap varwidth(50) mtitles












