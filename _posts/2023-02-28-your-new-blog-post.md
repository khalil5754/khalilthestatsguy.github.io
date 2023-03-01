## Using MS SQL for Performance and Power BI for Actionable Insights:

What is normalization?

To avoid redundant data, normalization transforms a dataset so it has a standard scale. The goal is to make the dataset easier to compare and analyze. For example if we had our penguin weight in grams, but our penguin's heights were in feet (or inches), we could choose to normalize the two by converting both to percentiles or the same unit of measure. More commonly, normalization is used to turn a skewed distribution into a normalized or "symmetrical" distribution, becoming easier to apply statistical analysis to.
Denormalization, on the other hand, our focus is not on reducing redundancy but improving search capability. This is because when one reduces redundancy in a SQL table, the redundancies are moved to external tables, thus it becomes more time-consuming and resource-heavy to run queries on these multiple tables. Denormalization takes the split tables and merges them into one single table.

When you have a system wherein you are inputting or loading data into a database, typically you want to normalize the data to make it more lightweight and less redundant. However, when you want to pull data from the table, you want the searching time for SQL to be as short as possible, which is when you would want to implement de-normalization.

In high-capacity systems, such as databases with millions of lines of code, you will typically need two databases. The OLTP database that is normalized for maximum updating, deleting, or inserting efficiency, and the OLAP system which is denormalized is intended to be for fast SELECT statements and queries. These databases work in tandem and form the bedrock of the ETL (Extract, Transform, Load) process, which we'll go over in further detail in a future post.


## The normalization process: 1st, 2nd, and 3rd normal forms

Remember APT: Atomic, Partial, Transient.
1st normal form: No repeating groups. This essentially means if you load your dataset as a csv, there should be no more than one input per cell. If this is not the case the columns should be split to ensure atomic (unique) values.
2nd normal form: 1st normal form rules still apply, but all non-key columns should be _fully_ dependent on the primary key. This can be achieved by splitting a table to ensure each column is fully dependent on the PK.
3rd normal form: All previous form rules still apply, but without transient dependency. This means no non-key column should depend on any other non-key column.

To achieve normalization in SQL, we can create a series of tables and relationships using SQL statements such as CREATE TABLE, ALTER TABLE, and JOIN. For example, in order to create a normalized database for a customer orders system, we can create separate tables for customers, orders, and order details, with relationships between them based on the customer ID and order ID.

Here's an example of a CREATE TABLE statement for a normalized customer table:

```
CREATE TABLE Customers (
   CustomerID int PRIMARY KEY,
   FirstName varchar(50),
   LastName varchar(50),
   Email varchar(100),
   Phone varchar(20),
   Province varchar(50),
   TotalPurchase int(10)
);
```

## Unique Key VS. Primary Key

Simple, primary keys can not have nulls, but unique keys can have nulls. Also, there can only be one primary key while there can be many unique keys.

Why are we using char instead of varchar or nchar? Well char is a fixed character length, while varchar is flexible. The n in ncode, on the other hand, makes it so non-english inputs work - however, this means unicode is supporting which will make each char 2 bytes. 


## How can we increase the performance of our MS SQL query? 

This is an _excellent_ question. First, you can use indexes to increase search performance in MS SQL. Imagine you have a dataset that spans numbers 1-100. What indexing does is build two nodes to make searching through the dataset faster. The first node can be values less than or equal to 50 and of course spans 1-50, while the second node would be all values greater than 50, and spans 51-99. This way, if we want SQL to pull the number 68, it knows immediately to ignore the first node and thus cancels out half of the work.
That index is referred to as a clustered index, but indexes can also be more high-level and store no actual data but instead point to the clustered index nodes which do store the actual data.

To create an index, MS SQL has the CREATE INDEX function, which just needs to know which column and which table you want to use to create the index. Here's an example using our previous table: 

```
CREATE INDEX idx_total_purchase ON TotalPurchase (Customers);
```

Important to note is that while indexes do increase performance, there are still some drawbacks to consider. Indexing requires more storage space for our newly created nodes, and they will also create a slight slowdown in write speed.


## Using SQL Server's Unique Merge Function

SQL Server and MySQL share many similarities - their differences mainly come from scalability (SQL Server scales better) and security wherein SQL Server is also inherently more secure due to built-in encryption and role-based access control. There are small functionality differences, such as the use of a MERGE command in MS SQL which can perform INSERT, UPDATE, and DELETE functions in just one line. The syntax differences are relatively small - LIMIT in MySQL is TOP in MS SQL and instead of CAST, MS SQL uses TRY_CONVERT. Overall for an enterprise focused on security, performance, and scalability, MS SQL is likely the right choice. 

Okay. Now let's work on a mini-project leveraging MS SQL - then see what Power BI can do with the data we pull. 

We have a table with the salary data of baseball players spanning over 100 years. Another table has the statistical performance of each baseball player. Let's look into our batters in particular. Only looking at years after 1984, which is when salary data became publicly available in the MLB, what is the correlation between the average number of home runs a player hits throughout their career, and their total career earnings?

We have but four columns we're concerned with: Year, Home Runs, PlayerID (PK), and Salary.
Let's see what we can do using the power of Common Table Expressions: 

```
WITH cte_homeruns AS (
    SELECT playerID, 
           AVG(NumberOfHomeruns) AS avg_homeruns 
    FROM batting
    WHERE TRY_CONVERT(int, year) > 1950 
    GROUP BY playerID
),
cte_salaries AS (
    SELECT playerID, 
           SUM(salary) AS total_salary 
    FROM salaries
    GROUP BY playerID
)
SELECT cte_homeruns.playerID,
       cte_homeruns.avg_homeruns,
       cte_salaries.total_salary
FROM cte_homeruns
INNER JOIN cte_salaries
ON cte_homeruns.playerID = cte_salaries.playerID
ORDER BY cte_homeruns.avg_homeruns DESC;

```
This new code uses a CTE to first filter out any records with invalid birthdates. It does this by casting the birthdate column as a date datatype using the CAST() function and then using the TRY_CONVERT() function to determine if the cast was successful. If the cast was successful, the record is included in the main query, which pulls data from the CTE. The cte_salaries query simply exists to calculate the SUM of each player's career earnings. Finally, we select all columns from the PlayerStats CTE and order the results by the average home runs in descending order.

To improve performance, we can also add indexes on the batting and salaries tables on the playerID and year columns, as these are used in the WHERE clauses for filtering the data. For example, we can create the following indexes:

```
CREATE INDEX idx_batting_player_year ON batting(playerID, year);
CREATE INDEX idx_salaries_player_year ON salaries(playerID, year);
```

These indexes will improve query performance by allowing the database to quickly find the relevant rows for each player and year, without having to scan the entire table.

Now let's create a Power BI model to put the data in perspective:

![Screenshot 2023-03-01 at 2 00 45 PM](https://user-images.githubusercontent.com/44441178/222240200-f8608d44-0dd0-4112-91c7-a2900e6c48cd.png)

While this may have what we're looking for, it may have been better to only show players who have hit more than 10 home runs in their career. After all, this is a dataset with _every_ batter in the last 100+ years, and the vast majority of batters in history haven't hit very many, if any, home runs. We can use Power BI to filter any players with less than 10 home runs. 

![Screenshot 2023-03-01 at 2 01 57 PM](https://user-images.githubusercontent.com/44441178/222240641-53df51b2-fead-4b11-b5ee-0bc45394401c.png)

Wow! There is an obvious correlation, but Power BI can of course go even further. Let's next add in a table that can match the playerID's with the player's full names, and see who the highest salary batters are.