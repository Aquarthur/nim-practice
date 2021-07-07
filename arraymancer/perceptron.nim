import arraymancer, sequtils, strformat

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

proc predict(p: var Perceptron, x: Tensor[float]): float =
  let weighted_sum = p.W.transpose().dot(x)
  return p.activation_function(weighted_sum)

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

let input_matrix: Tensor[float] = @[
  [0.0, 0.0],
  [0.0, 1.0],
  [1.0, 0.0],
  [1.0, 1.0]
].toTensor()

let desired = @[1.0, 1.0, 1.0, 0.0].toTensor()

let binary_step = proc (x: float): float = (if x >= 0: 1 else: 0)

var perceptron = Perceptron(learning_rate: 0.1, epochs: 50, activation_function: binary_step, bias: 1)
perceptron.fit(input_matrix, desired)

var predictions = newSeq[float]()
for i in 0..input_matrix.shape[0]-1:
  let prediction = perceptron.activation_function(
    perceptron.W[0] + (perceptron.W[1] * input_matrix[i, 0]) + (perceptron.W[2] * input_matrix[i, 1])
  )
  predictions.add(prediction)

echo &"\nTraining finished. Final W: {perceptron.W.toSeq()}\n"
echo &"Desired outcomes: {desired.toSeq()}\n"
echo &"Predictions: {predictions}\n"
