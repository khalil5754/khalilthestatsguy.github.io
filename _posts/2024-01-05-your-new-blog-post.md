# PROJECT: Building PlantTime.com - a Plant Recommendation System (Using AWS DynamoDB, Cloudformation, Lambda, and a CI/CD Github Workflow)


**This is a WIP**


PlantTime URL: planttime.ca (Front-end deployed Jan. 30, 2023)

#### Preliminary

First thing's first, what do we want to build? I don't want to spend too much time on this part as the point of this post is to document the building process. 

Myself and my front-end developer friend had a great idea for a website we'd both enjoy wherein a user can enter their location, the date they want to begin to grow a plant and the soil they have. The website will recommend a plant to them based on a multi-dimensional
ML model, built by yours truly, taking into account precipitation, UV index, elevation, soil type, season, and forecasted (by the model) weather! The site will also display a "Plant of the Week" and the back-end data will be used to build 1-2 graphs from the data.

My friend is a very talented front-end dev but he knows nothing about back-end work, so I'll be taking care of anything involving the back-end systems.
This means I'll be **architecting the system design, building the database (with high-availability and scalability), setting up endpoints, and automating API querying!**


Okay, let's get started.


#### Groundwork

To lay the groundwork for this project I'm first going to be using a weather API from [open-meteo.com](https://open-meteo.com). The first time we load this data in to look at it, we simply call the API with Python (you can just use your browser or "curl"
in your terminal, but that's less fun):

```
import requests
url = 'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&daily=weathercode,temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_sum&timezone=America%2FNew_York&start_date=2022-09-30&end_date=2023-10-05'
resonse = requests.get(url)

weather_data = response.json() #Convert the output into a JSON for parsing
print(weather_data)
```
What this returns is a JSON of the weather data, in the form:  

```
{'latitude': 52.52, 'longitude': 13.419998, 'timezone': 'America/New_York', 'timezone_abbreviation': 'EDT', 'elevation': 38.0, 'daily_units':
{'time': 'iso8601', 'weathercode': 'wmo code', 'temperature_2m_max': '°C', 'temperature_2m_min': '°C', 'uv_index_max': '', 'precipitation_sum': 'mm'}, 'daily':
{'time': ['2022-09-30', '2022-10-01', '2022-10-02', '2022-10-03', '2022-10-04] 

'temperature_2m_max': [5.7, 5.6, 6.1, 8.3, 3.8]

'uv_index_max': [2.0, 2.55, 1.75, 2.3, 3.4]

'precipitation_sum': [18.7, 2.9, 1.8, 0.0, 3.6]
```

There is a lot more data being pulled, but that should give you a solid idea. Of course whatever DB we use is not going to take this 
data as it is, so we have to parse it and input it into our database. The plan is to insert the past year's data into our database so
that we can have our graphs show historical weather data for comparison with the current weather. 

We also want to build an ML forecasting model but that will likely be out of the scope of this post, but tune in for a 
future post about it.



#### Parsing, Lambda, and DynamoDB

Okay, now I have to quickly explain why I chose DynamoDB over RDS or Redshift. This comes down to exactly one reason: cost.
While RDS and Redshift charge no matter how much you're using the DB, DynamoDB scales down to 0 if no-one is using it.
This comes at a cost of slower response time if it's the first time someone queries the website in a while, but this is a price I'm
willing to pay to avoid the price of RDS and Redshift (get it?).

Let's parse the data. 

First, You'll notice that our "weather_data" dictionary has a key called 'daily', which itself is another dictionary. Within this 'daily' dictionary, there are other keys like 'time', 'weathercode', 'temperature_2m_max', and so on. Each of these keys maps to a list.

The key idea is that these lists are parallel. This means the first element in the 'time' list corresponds to the same day as the first element in the 'weathercode' list, 'temperature_2m_max' list, and so on.

What does this mean? We can use a for loop to parse!
Specifically, if we do:

```
for i in range(len(weather_data['daily']['time'])):
```

This will make it such that we're setting up a loop that iterates once for each element in the 'time' list. The iterator 'i' 
takes on values from '0' to the lenth of the dictionary.

Here's the full for loop:

```
for i in range(len(weather_data['daily']['time'])):
            date = weather_data['daily']['time'][i]
            weathercode = weather_data['daily']['weathercode'][i] or 0
            temperature_max = weather_data['daily']['temperature_2m_max'][i] or 0.0
            temperature_min = weather_data['daily']['temperature_2m_min'][i] or 0.0
            uv_index_max = weather_data['daily']['uv_index_max'][i] or 0.0
            precipitation_sum = weather_data['daily']['precipitation_sum'][i] or 0.0
```



Inside the loop when we access weather_data['daily']['time'][i], we're getting the i-th element of the 'time' list. Since the data is parallel and the one thing that should never be or end early is the date, this is the safest bet to iterate our loop on! So on the first loop iteration (when i is 0), this would get us '2022-09-30'. On the second iteration (when i is 1), it would get us '2022-10-01', and so forth. Also, this gets us the same parallel data per dictionary.

Alright, so that's the basics of our Lambda function for parsing the weather data from the API. Of course there's more to the code than this, but that's the meat and potatoes. Now we can Zip this file, upload it into an S3 bucket and build our Cloudformation YAML template. More on that in the next section. **Note:** For the zip file, what I did is use a git environment in my terminal for version control, so that I can keep track of my changes and revert back to an old version if something goes wrong. You don't have to do this, but it helps in case you make a mistake.

Now, let's talk about CloudFormation:


#### CloudFormation

CloudFormation is an incredibly powerful tool which allows us to use a simple YAML file (or a JSON) to essentially build and deploy our app automatically. This allows us to migrate to other AWS accounts (or other cloud service providers) with ease, since our YAML can be deployed anywhere. We can feed CloudFormation a YAML such as this one, which "executes" our Lambda functions from a zip file in our S3 bucket:

```
Resources:

  # Lambda IAM Role
  LambdaExecutionRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service:
                - lambda.amazonaws.com
            Action:
              - sts:AssumeRole
      Policies:
        - PolicyName: AccessDynamoDB
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:PutItem
                Resource:
                  Fn::Sub: arn:aws:dynamodb:${AWS::Region}:${AWS::AccountId}:table/weather_data

  # Lambda Function to Update Weather Data
  WeatherDataUpdaterFunction:
    Type: 'AWS::Lambda::Function'
    Properties:
      Handler: 'weather_parser.lambda_handler' 
      Role:
        Fn::GetAtt:
          - LambdaExecutionRole
          - Arn
      Code:
        S3Bucket: 'weatherparsing'
        S3Key: 'function.zip'
      Runtime: 'python3.8' 
      Timeout: 15
      MemorySize: 256

  # CloudWatch Event Rule
  WeatherEventRule:
    Type: 'AWS::Events::Rule'
    Properties: 
      Description: 'Trigger the weather Lambda function every 7 days'
      ScheduleExpression: 'rate(7 days)'
      State: 'ENABLED'
      Targets: 
        - 
          Arn: 
            Fn::GetAtt: 
              - "WeatherDataUpdaterFunction"
              - "Arn"
          Id: "TargetFunctionV1"

  # Permission for the CloudWatch Event Rule to trigger Lambda Function
  LambdaInvokePermission:
    Type: 'AWS::Lambda::Permission'
    Properties: 
      Action: 'lambda:InvokeFunction'
      FunctionName: 
        Ref: "WeatherDataUpdaterFunction"
      Principal: 'events.amazonaws.com'
      SourceArn: 
        Fn::GetAtt: 
          - "WeatherEventRule"
          - "Arn"


```

Just like that, CloudWatch will execute the YAML, spinning up the AWS services we need quickly and almost simultaneously. That being said, it's *extremely* important to ensure the YAML file is correct prior to running it to avoid spinning up an AWS service you don't mean to. Been there - it's an expensive mistake. 

What does our YAML do after executing the S3 zipped up Lambda functions? Something very cool. Not only does it spin up our AWS services, but it also automatically deposits the output data into DynamoDB. It also set up an event rule for EventBridge for us, which is an automated script that runs upon some trigger. In this case, our trigger is simply a time-frame of 7 days. Perfect, every 7 days our weather data will update. I could have manually done this, but again, I want this to be as automated as possible. 

Okay, now let's assume I got all this working on the first try (I totally did). Next, we can get to the fun part. We want to build some kind of recommendation algorithm to recommend plants based upon the user's location, the time of the year, the weather (specifically the sunlight), and a few other variables. To do this, there are many similarity equations or machine learning models to choose from.


#### Cosine Similarity Recommendation System

I had actually never heard about "Cosine Similarity" prior to researching how to accomplish our task. I stumbled upon a similarity measurement called cosine similarity - a measurement that quantifies the similarity between two or more vectors. The cosine similarity is the cosine of the angle between vectors and these vectors are typically non-zero within an inner product space. Frankly, this seemed way too easy. I almost didn't use it because I thought I wanted something more complicated but I soon realized that this was exactly what I was hoping for - and too simple is better than too complicated. 

Here's the equation (from Wikipedia):

![image](https://github.com/khalil5754/khalil5754.github.io/assets/44441178/2a716af2-c13c-4e89-86db-9e7ef436c6cc)


Luckily for us, scikit-learn has a cosine similarity library! Unluckily for us, I want this code to be as fast and light as possible - and due to the simplicity of the formula and the large size of the scikit-learn library, this means I'm going to manually code cosine similarity. I turned something simple just a tad complicated :).

Let's quickly go over the pre-processing steps to accomplish this:

```
# creating plants dataframe
plants_response = plants_table.scan()
plants_items = plants_response['Items']
plants_df = pd.DataFrame(plants_items)

watering_mapping = {
    'Must dry between watering & Water only when dry': 0,
    'Water only when dry & Must dry between watering': 0,
    'Water when soil is half dry & Water only when dry': 0,
    'Keep moist between watering & Can dry between watering': 1,
    'Water when soil is half dry & Can dry between watering': 1,
    'Keep moist between watering & Water when soil is half dry': 2,
    'Water when soil is half dry & Change water regularly in the cup': 2,
    'Change water regularly in the cup & Water when soil is half dry': 2,
    'Keep moist between watering & Must not dry between watering': 2,
}

# apply the updated mapping to the 'Pruning' column
plants_df['Watering'] = plants_df['Watering'].map(watering_mapping)


pruning_mapping = {
    'Never': 0,
    'After blooming': 1,
    'If needed': 1,
    'Fall': 1
}
```

We need numerical features for cosine similarity to work, so we map each categorical feature we need to a numerical value. In doing so, we have a little leeway in how we want to interpret each categorical value. For example, with regard to pruning, I've chosen to essentially have two groups: "needs pruning" and "does not need pruning". This was done for simplicity as we can determine if our users was a high-effort or low-effort plant, and the algorithm will not differentiate between these two groups. I've also consolidated some of the "watering" categories, to create just 3 groups: "rarely water", "water sometimes", and "water often". We can do this with any features, not necessarily just categorical features, for example, with regard to plant height we can do something like this to group the plants into "big", "medium", and "small". 

```
def classify_size(height):
    if height <= 100:
        return 0
    elif 100 < height <= 500:
        return 1
    else:
        return 2
```

What do we do next? Well we want to know the weather going forward, so we grab the future weather from today onward:

```
# query for Calgary weather from today onwards
user_location = 'Calgary'
today = datetime.now().strftime("%Y-%m-%d")  # Adjust date format as per your table
weather_df = query_weather_data(user_location, today)

# calculate user's weather preferences
user_temperature_max = math.floor(weather_df['Temperature_max'].mean())
user_temperature_min = math.floor(weather_df['Temperature_min'].mean())
user_effort = 'medium'

```

This is a basic example which gives us the next 12 weeks' weather (predictive based on last year's averages) and a pre-input user location (this will be input manually by the user or automatically by their browser if they accept). We calculate their weather preferences and take the floor of the next 12 weeks' average max and min temperature to ensure the plant will survive the next few months.

We now have a cosine-similarity ready dataset, the weather for the next 12 weeks, the user location, and their ideal effort level.

