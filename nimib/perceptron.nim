import nimib

nbInit

nbText: """# Single-Layer Perceptron in Nim

Let's try out nimib as a tool and go through making a perceptron. We'll be using `arraymancer`, but only for its tensors.
It has its own implementation of perceptrons and other bits and pieces implemented here but the goal was to do as much from scratch
as possible!

Please note that a lot of the code found here has been translated to Nim from
[PythonMachineLearning's](https://pythonmachinelearning.pro/perceptrons-the-first-neural-networks/) excellent article.
"""

nbText: """## Perceptrons

In the future, this is where I might decide to have a small blurb about what perceptrons are. As it stands though, I'll focus on just
learning to use nimib a bit.
"""

nbText: """## Setting up

To start with, we'll want to import libraries that we'll be using in this implementation. `arraymancer` is to Nim, what `numpy` is to Python.
The other libraries are imported for some utility functions and some nice and sugary syntax.
"""

nbCode:
  import arraymancer, sequtils, strformat

nbText: """## Implementing the Perceptron

A perceptron has a few hyperparameters that you'll want to pass in. Unlike Python, Nim does not have classes per-se, but instead types that you
can attach methods to. We'll start by creating the `Perceptron` type and adding hyperparameters as fields, and add a function to initialize
the weight matrix:
"""

nbCode:
  type
    Perceptron = ref object
      W: Tensor[float]
      bias: float
      learning_rate: float
      epochs: int
      activation_function: proc (i: float): float
      verbose: bool

  proc init_weights(p: var Perceptron, input_size: int) =
    p.W = zeros[float](input_size + 1)

nbText:"""Next, we want to implement the `predict` function, which takes the input vector, inserts the bias, is dot-multiplied with the weight
matrix, and is run through the defined activation function.
"""

nbCode:
  proc predict(p: var Perceptron, x: Tensor[float]): float =
    let weighted_sum = p.W.transpose().dot(x)
    return p.activation_function(weighted_sum)

nbText: """Finally, putting it all together:"""

nbCode:
  proc update_weights(p: var Perceptron, input_vector: Tensor[float], error: float) =
    p.W = p.W + (p.learning_rate * error * input_vector)

  proc fit(p: var Perceptron, input_matrix: Tensor[float], desired: Tensor[float]) =
    assert input_matrix.shape[0] == desired.shape[0]
    p.init_weights(input_matrix.shape[1])
    for epoch in 0..p.epochs-1:
      for i in 0..input_matrix.shape[0]-1:
        # Couldn't find an easy "insert" operator
        let input_vector = @[p.bias, input_matrix[i, 0], input_matrix[i, 1]].toTensor()
        let prediction = p.predict(input_vector)
        let error = desired[i] - prediction
        p.update_weights(input_vector, error)

nbText: """## Testing things out

Now that we've implemented the perceptron, let's test it out!
"""

nbCode:
  let input_matrix: Tensor[float] = @[
    [0.0, 0.0],
    [0.0, 1.0],
    [1.0, 0.0],
    [1.0, 1.0]
  ].toTensor()

  let AND_desired = @[1.0, 1.0, 1.0, 0.0].toTensor()

  let binary_step = proc (x: float): float = (if x >= 0: 1 else: 0)

  var perceptron = Perceptron(learning_rate: 0.1, epochs: 50, activation_function: binary_step, bias: 1)
  perceptron.fit(input_matrix, AND_desired)

  var AND_predictions = newSeq[float]()
  for i in 0..input_matrix.shape[0]-1:
    let prediction = perceptron.activation_function(
      perceptron.W[0] + (perceptron.W[1] * input_matrix[i, 0]) + (perceptron.W[2] * input_matrix[i, 1])
    )
    AND_predictions.add(prediction)

  echo &"\nTraining finished. Final W: {perceptron.W.toSeq()}\n"
  echo &"Desired outcomes: {AND_desired.toSeq()}\n"
  echo &"Predictions: {AND_predictions}\n"

nbText: """You should see something like the following after running the code:

```nim
Training finished. Final W: @[0.2, -0.2, -0.1]

Desired outcomes: @[1.0, 1.0, 1.0, 0.0]

Predictions: @[1.0, 1.0, 1.0, 0.0]
```
"""

nbShow
