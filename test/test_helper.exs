Code.put_compiler_option(
  :parser_options,
  Keyword.put(Code.get_compiler_option(:parser_options), :token_metadata, true)
)

ExUnit.start(exclude: [skip: true])
