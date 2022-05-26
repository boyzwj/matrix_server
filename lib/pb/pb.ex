defmodule PB do
  @external_resource "./proto/common.proto"
  @external_resource "./proto/system.proto"
  use Protox,
    files: [
      "./proto/common.proto",
      "./proto/system.proto"
    ]
end
