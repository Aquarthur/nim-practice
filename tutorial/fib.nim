import strutils

proc fib(n = 0): int =
    if n < 2:
        return n
    else:
        return fib(n-1) + fib(n-2)

stdout.write "Please provide the argument to the fib sequence: "
var n: int = parseInt(readLine(stdin))
echo "Result: ", fib(n)

