defmodule Temple.Support.Components do
  use Temple.Support.Component

  def basic_component(_assigns) do
    temple do
      div do
        "I am a basic component"
      end
    end
  end

  def default_slot(assigns) do
    temple do
      div do
        "I am above the slot"
        slot @inner_block
      end
    end
  end

  def named_slot(assigns) do
    temple do
      div do
        "#{@name} is above the slot"
        slot @inner_block
      end

      footer do
        for f <- @footer do
          span do: f[:label]
          slot f, %{name: @name}
        end
      end
    end
  end

  def rest_component(assigns) do
    temple do
      div do
        "I am a basic #{@id} with #{@class}"
      end
    end
  end

  def rest_slot(assigns) do
    temple do
      div do
        for foo <- @foo do
          slot foo, slot_id: foo.id, rest!: [slot_class: foo.class]
        end
      end
    end
  end
end
