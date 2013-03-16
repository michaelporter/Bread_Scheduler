module TimeManipulation
	def in_seconds(type, number)
    case type
      when :min
        number * 60
      when :hour
        number * 60 * 60
    end
  end
end