# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [
    locals_without_parens: [
      htm: 1,
      partial: :*,
      flex: :*
      div: :*
    ]
  ]
]
