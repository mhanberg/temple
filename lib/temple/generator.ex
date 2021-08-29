defprotocol Temple.Generator do
  @moduledoc false

  def to_eex(ast, indent \\ 0)
end
