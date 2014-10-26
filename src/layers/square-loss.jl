############################################################
# Square Loss
#
# L(\hat{y},y) = 1/N \sum_{i=1}^N (\hat{y}_i - y_i)^2
############################################################
@defstruct SquareLossLayer LossLayer (
  (tops :: Vector{String}, length(tops) == 1),
  (bottoms :: Vector{String}, length(bottoms) == 2)
)

type SquareLossLayerState <: LayerState
  layer :: SquareLossLayer
  blobs :: Vector{Blob}
end

function setup(layer::SquareLossLayer, inputs::Vector{Blob})
  data_type = eltype(inputs[1].data)
  blobs = Blob[Blob(layer.tops[1], Array(eltype, 1))]

  state = SquareLossLayerState(layer, blobs)
  return state
end

function forward(state::SquareLossLayerState, inputs::Vector{Blob})
  pred  = inputs[1].data
  label = inputs[2].data

  dims = size(pred)
  batch_size = dims[1]
  rest_dim = prod(dims[2:end])

  pred  = reshape(pred, (batch_size, rest_dim))
  label = reshape(label, (batch_size, rest_dim))

  state.blobs[1].data[:] = mean(sum((pred - label).^2, 2))
end

function backward(state::SquareLossLayerState, inputs::Vector{Blob}, diffs::Vector{Blob})
  if length(diffs) == 1
    pred  = inputs[1].data
    label = inputs[2].data
    diffs[1].data[:] = 2*(pred - label) / size(pred.data,1)
  end
end

