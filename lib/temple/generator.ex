defprotocol Temple.Generator do
  @moduledoc false

  def to_eex(ast)
end
