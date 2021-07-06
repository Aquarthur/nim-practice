# Jester thoughts

While writing the very basic example I have here, there were a few issues:

* Using Postman, I'd alternate between POST and GET requests quite often. If I left the payload from a POST request in a GET request, it would never complete. In other languages/frameworks that I've used, the body essentially just gets ignored. Made testing things out a bit more painful.
* Speaking of making things painful, the error messages were really not particularly helpful while developing. I had to figure out a lot of things on my own by reading code in the Nim standard libraries to find out what the issue was.

On the bright side, the (super basic) TODO API is fairly concise and reads well. However, I'm not sure that the benefits outway the negatives for now.

Obviously, I'm new to Nim so I may be missing out on some obvious things.
