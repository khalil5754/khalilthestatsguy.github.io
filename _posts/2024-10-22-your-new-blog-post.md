# Golang (Go) With Databases
  While Python has been the dominant language in the data science community for many years, Go (also known as Golang) is emerging as a powerful and versatile language for data scientists.

Go is a statically typed, compiled language that was developed by Google in 2009. It's generally known for its simplicity, concurrency, and performance, making it well-suited for building scalable and efficient systems. 

In this blog post, we will look at some of the popular Go libraries and tools for data science, such as Gorgonia, Gonum, and Gota, and how they can be used to build data pipelines and perform machine learning tasks.

By the end of this blog post, you will have a better understanding of why Go is a valuable language for data scientists, and how it can be used to tackle real-world data science problems.

First, the basics. Let's write a very simple function just to show you what Go syntax looks like.

```
package main

import "fmt"

func main() {
	var number int = 299
	number = number + 1
	fmt.Println(number)
}

```

"fmt" is a package in Go's standard library that provides functionality for formatting and printing text. Things like print statements and specific formatting is done using fmt. In the above code block, the variable "number" was declared as an integer 


# Explicit Vs. Implicit 
  
In the above code block is an example of an explicit definition of a variable. That is, we've told Golang _explicityly_ what type of variable "number" should be. However, if we drop the "int" and just have golang decide on a type for us, this is called an _implicit_ definition. For example:

```
func main() {
	var number = 299
	fmt.Printf("%T", number)
}
```

Using "Printf" tells Go that we want it to print formatting, while "%T" tells it to give us the type of the variable we've passed it - which in this case is "number". Go guesses the type is an int, of course. If we were to add quotation marks around the integer, then it would surely assume it's a string!

There is an even easier way to declare a variable in Golang using what is called an expression assignment operator or more preferably, the walrus operator. While I'm showing you that I'll also throw a basic if-else statement into the mix to show you how we can use printf, as well as to show basic syntax in Go.

```
func main() {
	height := 149
	
	if height > 150 {
		fmt.Println("You are tall enough to ride")
	} else {
		fmt.Printf("You are %dcm too short to ride", 150-height)
	}
	
}
```
Here we have a basic walrus operator wherein we implicitly declare and set a variable "height". If the patron's height is greater than 150cm, they are able to ride. Otherwise, the else statement tells them how many centimetres too short they are from being able to ride. This is done using %d to pass some basic arithmetic to our print statement. 


## Pointers

Just like C, pointers are a big part of what makes Go so powerful. We use the ampersand "&" to denote a pointer and asterisk "*" to dereference a pointer.

For example, say we had the below program and we hit run - what do you expect to happen? If you think it's going to print "2", you'd be wrong. What it actually does is print the location of where the value has been stored. 

```
package main
import "fmt"

func main() {
	x := "testing"
	y := &x
	fmt.Println(y)
}
> 0xc0000100a0
```

When we use &, we're telling Go we want to access the _location on our memory_ that variable x is stored. However, if we add our dereference operator * in front of y as such: 

```
func main() {
	x := "testing"
	y := &x
	fmt.Println(*y)
}
> testing
```

We get the actual value being stored at the location on our memory.

This was just a bit of a passion project for me, as I've really wanted to learn Go for a long time. I'm enjoying it a ton, but my Master's degree starts in a few days so I think I'll be focusing a lot more on Python and SQL than Golang, but I'll be back to give you guys more info before you know it :)

- KhalilTheStatsGuy
