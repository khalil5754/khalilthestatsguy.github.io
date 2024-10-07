# Useful Statistical Correlation Techniques: Pearson, Spearman, and Kendall 

### As a Data Scientist you might hear the terms: Kendall, Granger, Pearson, Spearman, or CCF often
#### "...What?"

Let me explain. In statistics, there are a _ton_ of statistical tools at your disposal to determine correlation. But like any good blacksmith, knowing which tool to unsheath and when is the most important factor differentiating a good data scientist/statistician from a mediocre one.

In this part, we'll be focusing on Pearson, Spearman, and Kendall.

First, to cover the Python libraries you should import anytime you need to use statistical tools, the very basics include:

```
import numpy as np
import pandas as pd
import seaborn as sns
import scipy.stats as stats
```

For example, sometimes there are instances when you want to determine if a variable has a correlation with another variable - given a time-series.


Some statistical correlation coefficient calculations will need their own unique libraries, but the above code block is a safe start.

Let's now consider the most common and easy to use correlation coefficient. First, in 99% of the cases where you're looking for simple correlation between two variables, you want to use:

## Pearson r correlation:

Here's the equation for the parametric Pearson correlation:

![image](https://user-images.githubusercontent.com/44441178/195477911-6228d60b-fcc8-4f6f-bec4-b68ce0bd8da4.png)


Where:
r(xy) = Correlation coefficient of variable "x" with respect to variable "y"

n = total number of observations

xi = value of x (for ith observation)

yi = value of y (for ith observation)

#### Required Limitations for Pearson Correlation: 
Normal distribution - this just means the data must be a bell-shaped curve (you can normalize data yourself if necessary! But that's a topic for another day)
Linear relation - Simply put, both variables must have a straight-line relationship.

**Usage Example:** Looking at two stocks and attempting to determine if they're correlated, and if so to what degree of correlation? Pearson's your man!
If you have Pearson's correlation coefficient formula in your back pocket, so long as you're not doing anything regarding determining if one time series can serve as a predictor of another, or dealing with any heteroskedastic data, you're golden using Pearson (but don't forget to normalize your data!)


Python is of course very user-friendly, at least relative to other languages (looking at you C++).
As a result, implementing most statistical correlations is incredibly simple, you just call the df.corr() function, a built-in function in pandas.

##### How to Implement Pearson Correlation in Python:

```
import pandas as pd
print(df.corr())

#Returns:
           $MSFT     $AAPL
    MSFT  1.000000  0.930912
    AAPL  0.930912  1.000000
```

![Screen Shot 2022-10-12 at 9 53 16 PM](https://user-images.githubusercontent.com/44441178/195480491-6a3ad1cd-c7a3-4b99-96c6-3ded458fb207.png)

Looks like a very strong correlation here!



## Next, lets look at the Spearman Correlation

It's crucial to understand the Pearson correlation _before_ Spearman.
As previously stated, for a Pearson correlation to be used, a linear and bell-shaped relationship (normally distributed) is required.

However, there will be times when the data being used does not satisfy these requirements.

This is where Spearman comes to the rescue. 
**Limitation:**
Spearman's correlation function can only be used to measure monotonic relationships (If you don't know what these are, see my blog post - monotonic vs non-monotonic relationships)
Spearman's correlation is also non-parametric.

**Equation: **

![image](https://user-images.githubusercontent.com/44441178/195489432-c7c2c7c5-6326-46d2-ab51-ffda69c020bb.png)

Where:
p = Spearman correlation
di = Difference between correlation of corresponding variables
n = Total number of observations
Given a monotonic relationship, Spearman's correlation coefficient will show the strength of correlation between two variables. This coeffecient takes the form of:

-1 ≤ r ≤ 1

Where -1 is a very strong negative correlation, and 1 is a very strong positive correlation. 

Let's look at an example of what happens when using the wrong correlation coefficient equation for a given data set:

![Screen Shot 2022-10-12 at 10 15 08 PM](https://user-images.githubusercontent.com/44441178/195483279-6f86b223-387f-4fa4-93b5-b698a871e572.png)

Here, we can see a clear monotonic relationship. Let's see what happens if we implement a Pearson correlation coefficient:

```
print(df.corr())

#Returns

>0.66904
```
A Pearson correlation coefficient of 0.67 indicates a non-perfect relationship. This is incorrect.

To create a Spearman scatter plot in Python, it's a little more complicated than Pearson:

```
def graph_spearman(df,title,color="green"):    
    fig, ax = plt.subplots(ncols=len(df.columns)-1,figsize=(14,3))
    for x in range(1,len(df.columns)):
        ax[x-1].scatter(df["X"],df.values[:,x],color=color)
        ax[x-1].title.set_text(title[x] +'\n = ' + "{:.2f}")
        ax[i-1].set(xlabel=df.columns[0],ylabel=df.columns[i])  
    plt.show()
    
graph_spearman(example_sprman,["X","2X+1"])
```

By plotting the data set, we have a clear monotonic relationship, i:

![image](https://user-images.githubusercontent.com/44441178/195486030-62c39acf-2b71-4656-b5dc-7efcc4e03a0e.png)

Important to note - a Spearman correlation does not _require_ a monotonic function, the function simply measures monotonicity. This means a coefficient value of 0 doesn't mean that there is no relationship. Instead, it means the relationship is non-monotonic.

For example, the above quadratic equation would return a Spearman correlation of 0. This (obviously) does not in any way mean there is no correlation.

If you're not interested in plotting the spearman correlation coefficient, you can simply use the statstools spearmanr() function:

```
srmn, p_value = stats.spearmanr(df['Inward FDI Flow'], df['Avg. Closing Price'])
print(srmn)
print(p_value)
```

Which will return the aggregate spearman coefficient as well as the p-value.


**Usage Example:** A paired data set where as variable x increases, variable y either increases or decreases - for example, is there a correlation between an NBA player's age, and his salary? 



Finally, we'll explore what will likely be your least used statistical tool in your growing statistical toolbox:


## Kendall Correlation (or Kendall's Tau Coefficient)

The Kendall Correlation Coefficient is interesting because it's a mix between the Spearman, Pearson, and even a little but of CCF (see part 2) functions.
Kendall is a jack of all trades, but a master of none. It measures variable x's _dependency_ on variable y. This can be used in a multitude of ways.

**Equation:**



Below, you'll see a Kendall correlation built in Python (using scipy statstools) I used in my thesis to determine if the VIX's average closing price was _dependent_ on FDI flow, or vice-versa.

```
tau, p_value1 = stats.kendalltau(df['Avg. Closing Price'], df['Inward FDI Flow'])
print(tau)
print(p_value1)
```

Quite simple. 

**Limitations:**
Ordinal Data or Continuous Data
Just like the Spearman Correlation, Kendall measure the monotonicity of a relationship. 

**Usage Example: ** What is the correlation between a client's ranking of our company, and total shipping time?


While the Kendall Tau Coefficient serves to measure dependency, it may be better to use something like _Granger Causality_ for this purpose. I'm personally a huge fan of Granger Causality - but we'll go over that in Part 2.




Signing off,

Khalil (TheDataGuy)
