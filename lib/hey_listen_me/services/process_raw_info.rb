require_relative './register_event'

class ProcessRawInfo < Actor
  play ImportRawInfo, RegisterEvent
end
