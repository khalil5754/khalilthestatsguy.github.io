Using Visualizations to Analyze Canadian Foreign Direct Investment

#### For this post let's stick to a topic I know quite well and dive into...

#### A Tableau/Python analysis of my topic: Canadian Foreign Direct Investment.

![image](https://github.com/khalil5754/khalil5754.github.io/assets/44441178/c23050be-881e-4744-9ae7-4736f6234ec6)


To preface this post: My dataset comes from the OECD, or the Organization for Economic Co-operation and Development. The organization works with governments around the world to maintain and improve a centralized economic/developmental database. I wanted to look at Canadian Foreign Direct Investment (FDI) and build a story by connecting the OECD FDI dataset to other datasets. Data sources are all linked in their respective section - with the base dataset (FDI data) accessible [here](https://data.oecd.org/fdi/fdi-flows.htm). The FDI dataset is very simple, with just two columns: the countries, and the FDI inflow (can be in USD or % of GDP). This made it difficult to answer five questions with - especially questions I was interested in such as where FDI into Canada is coming from. That is why I will be using a few supportive datasets from equally reputale organizations. The first step of any data analysis pipeline is to gather data from reputable sources (in this case the OECD, Statistics Canada, and the Chicago Board Options Exchange), then clean the data using your method of choice (in this case using Python) _before_ engaging in any analysis. This post will be less of a tutorial and more of a short blog guided by insights gathered through Tableau. This is a very different style than the rest of my works, but I hope you enjoy it nonetheless!

##### Without further ado...

### How does Canadian Foreign Direct Investment (FDI) compare to the rest of the G7 countries? 

##### Objective 1: To analyze Canadian FDI and how it compares to the rest of the G7.


Foreign Direct Investment is a significant driver of the Canadian economy. In 2022, among the G7 nations, Canada had the second-highest proportion of inward FDI flow as a percentage of GDP (See Figure 1). This ratio highlights the level of foreign investments in relation to the overall economic output of the country, showcasing the role of foreign capital in fueling economic activities. The Canadian government’s use of FDI cannot be understated, with industries and cities seeing tremendous growth as a result of generous policy geared toward promoting and maintaining FDI. Some research regarding FDI “heavy-hitters” rank global economies based on total inward FDI flow. This is an inaccurate empirical measurement and statistically a poor method of analyzing economies which differ so significantly in scale. Canada, for example, has a GDP 1/20th the size of its southern neighbour, the United States, and a population just 1/10th the size. A more appropriate method of comparison is the percentage of its total GDP that an economy takes in as inward FDI flow. Of the G7, the only country which allocates a higher percentage of its GDP to FDI than Canada is the United Kingdom.

<img width="1499" alt="Screenshot 2024-02-14 at 11 56 15 AM" src="https://github.com/khalil5754/khalil5754.github.io/assets/44441178/6effdf37-02ed-4728-96ab-0f12962599f6">

###### Figure 1: FDI inward flow as a percentage of total GDP in 2022


FDI inward flow in Canada equated to just over 72% of the country’s 2022 GDP, an important concern arises regarding whether a high GDP to FDI ratio exposes the host economy to increased economic vulnerability. Sharp changes in FDI inward flow (from henceforth referred to as FDI inflow) will have an impact on the Canadian economic landscape and could increase Canada’s economic vulnerability. We will explore this in further detail when we examine the VIX index.


Obviously, from the above visualization it's clear Canada is one of the most FDI dependent countries in the G7. It’s also clear Canada has succeeded in attracting a significant amount of FDI to its economy, to the tune of approximately $0.72 for every dollar the country generates.

### **But _why_ do FMNE (Foreign Multinational Enterprises) consistently choose Canada to set-up base?**

##### Objective 2: To understand one of the reasons why Canada is chosen as a recepient of FDI.

### Well, for starters: Tertiary Education

##### Data accessible [here](https://data.oecd.org/eduatt/population-with-tertiary-education.htm)

While many global economies share Canada's desire to accept as much FDI as possible and thereby grow their economy, the Canadian economy is in a unique position as one of the most coveted destinations for foreign enterprises.

To determine which country to select as a host country for FDI, enterprises conduct thorough research of potential destinations and consistently end up selecting Canada as a top destination for measured reasons.

Intuitively, attracting FMNEs begins with an educated populace because enterprises want to hire adaptable employees that can be trained and trusted to produce positive results. An OECD published study found that a highly educated populace is the single biggest attractor of FDI. Taking this into consideration, examining the top FDI destinations in the world’s adult education levels reveals Canada as the distinct leader in tertiary (post-secondary) education. 


<img width="678" alt="image" src="https://user-images.githubusercontent.com/44441178/195230123-e5bc7bb1-6ce4-4b99-aa4b-9ba2199f54f8.png">

###### Figure 2: Tertiary Education as a Percentage of Population


With such a significant discrepancy in tertiary education between Canada and the second-place United States, a clearer picture begins to form as to why the seemingly small Canadian economy can go pound-for-pound (or dollar-for-dollar) with economic heavy hitters like the United Kingdom and the United States with regard to FDI intake. Canada places a heavy emphasis on the education of its citizens and reaps the rewards a highly educated populace offers its constituents. Foreign Enterprises seek employees that are trainable and skilled. Canada supplies that!



### Where is the FDI coming from?

##### Objective 3: Analyze where FDI in Canada is coming from. 

##### Data Accessible [here](https://www150.statcan.gc.ca/n1/daily-quotidien/230428/dq230428b-eng.htm)

Limiting FDI inflow to stable economies and trade allies reduces the risk of sudden divestment. Divestment is when a foreign investor decides to pull their capital back to their home country. This is very dangerous for the Canadian economy because as we saw, there is a relatively heavy dependence on FDI (relative to the rest of the G7). If too many investors divest at the same time, capital investments will dry up simultaneously in Canada. To Canadian lawmakers’ credit, most inward FDI comes from allied nations. The United Kingdom, Luxembourg, the Netherlands, and the United States together accounted for more than 70% of foreign investment into Canada in 2021, with the U.S. - Canada’s closest ally and trade partner - making up almost 50% of the total amount alone (see Figure 3). These are countries favoured by Canada for FDI due to sharing a rich history of bilateral relations.

<img width="385" alt="image" src="https://github.com/khalil5754/khalil5754.github.io/assets/44441178/d6a98ab9-7b14-48e0-92f6-c4f1bf8758db">

###### Figure 3: Composition of Canadian FDI inflow by country.



### Canadian FDI and the VIX index - is there an obvious relationship?

##### Objective 4: Plot historical FDI and VIX prices to see if there is an obvious relationship.

##### VIX Data accessible [here](https://www.cboe.com/tradable_products/vix/vix_historical_data)

The VIX market index was developed by the Chicago Board Options Exchange to track market uncertainty. It measures the market’s annualized implied volatility over the next 30 days. The VIX index’s 52-week high for each year will be used for this portion because taking the average yearly price of VIX makes it difficult to discern when a significant systemic shock has occurred. VIX is a forward-looking index calculated with a rolling 30-day window, meaning that in years where global shocks occur, VIX can spike and regress to the mean very quickly. It could also see small consistent rises because of S&P 500 companies’ earnings results, domestic interest rate hikes, as well as other economic factors across the stock market. A notable instance showcasing the importance of dates when the VIX peaks is when the index reached a 52-week high in October 2008, occurring during the global financial crisis and merely a month following the Lehman Brothers bankruptcy in September 2008. During this month, the VIX hit one of its historical highs, reflecting the substantial market uncertainty tied to the banking industry's financial turmoil and severe lack of market liquidity!


<img width="410" alt="image" src="https://github.com/khalil5754/khalil5754.github.io/assets/44441178/f59bae8a-c4fe-4dd0-b048-392c2215f6e9">

###### Figure 4: Canadian inward FDI Flow (in Millions) and annual VIX 52-week highs


It is difficult to see a relationship in this figure without using statistical analysis techniques to interpret the data due to the inherent time it takes for factors like global shocks or even market uncertainty to ripple through the economy and impact an investment as significant as FDI. To confidently interpret the data, statistical models are used to analyze linear time-series with a time-lag, such as a Granger causality test and cross-correlation methods. However, the two time-series graphs do follow a very similar pattern to each other. This tells us there is likely a relationship here, although further analysis is needed before a conclusion can be drawn.


### How restrictive is Canada with regard to FDI relative to the G7 and the OECD average?

##### Objective 5: Look into FDI Restrictiveness Index from the OECD to see where Canada stands relative to the G7.

##### Data accessible [here](https://www.oecd.org/investment/fdiindex.htm)

Canadian foreign economic policy is flexible and largely balanced. However, it is not without its faults – while flexible and balanced, Canada is ranked as one of the most restrictive countries to foreign investing.

OECD’s FDI Restrictiveness Index ranks countries by their acceptance of foreign investors, with a value of 1 indicating no foreign investors allowed to partake, and 0 indicating no investment restrictions whatsoever. Canada ranks number one among developed economies in overall restriction of FDI. This is surprisingly not in line with the premise of this post: if the government is so restrictive, why is FDI still flowing in in such significant quantities? The answer partially lies in the details.


<img width="730" alt="image" src="https://user-images.githubusercontent.com/44441178/195230082-275cd877-da46-41ee-9e77-4f8c261ed1c2.png">


###### Figure 5: OECD FDI Restrictiveness by Country. Highlighted Values in Red Indicate Restriction Coefficients Greater Than 0.1


Canada’s restriction coefficient is evidently high relative to its peers. The total is, however, certainly skewed up heavily due to Canada’s incredibly restrictive telecommunications and media industries. These are two industries that Canadian regulatory bodies consider “distinguished” Canadian sectors wherein it is vital that Canadian culture must be “protected”. 

Interesting. 

### Conclusion

The benefits of FDI are well-documented and highly touted by the Government of Canada as well as other proponents, but with widespread acceptance comes an important need to understand the risks. These risks can be blunted through transparency from the Canadian government regarding the risks associated with FDI, and an increased focus on domestic output to decrease dependency on foreign capital.

In this blog post we've looked at how Canada compares to the rest of the G7 with regard to FDI as a percentage of GDP and FDI restrictiveness. It was quite surprising to see Canada rank second in FDI as a percentage of GDP while also being the most FDI restrictive country according to the OECD index. It was also interesting to uncover that Canada has the highest proportion of tertiary-educated population relative to the rest of the G7. This helps explain why foreign firms choose Canada as the country to set up base. There are many more factors, such as taxes and foreign policy, that make Canada an attractive destination. The least surprising finding was seeing how Canada's FDI largely comes from the USA. However, it was insightful to see that 70% of Canadian FDI was from the USA, Netherlands, Luxembourg, and the UK (all historical Canadian allies). Finally, given more time and freedom I likely would have conducted a statistical analysis to better understand the relationship between VIX and FDI. This blog was never meant to be in-depth on the topic, but I figured I should write about something I'm passionate about.

Signing off,

Khalil 

