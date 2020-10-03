# Str2Binary
A program that takes a float in the format of a string and converts it to a binary coded using MIPS assembly language and run on MARS MIPS simulator
In MIPS assembly language there is not direct way to convert a float to a binary number
The process would be to take the float as a string input 
Convert each character in the string to an int
Then convert the numbers before the full stop to a float by moving the into the FP register
Convert the decimal (number after the full stop) by diving each point by 10 and increment to the next point, repeat this process until you have converted each floating point
Concatonate the whole number and the  decimal
Prepare registers for the binary conversion
convert the float to a binary 23 bit binary number
