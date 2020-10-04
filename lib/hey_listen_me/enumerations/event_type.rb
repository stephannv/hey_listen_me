class EventType < EnumerateIt::Base
  associate_values(
    :create,
    :update
  )
end
