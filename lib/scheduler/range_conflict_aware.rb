module RangeConflictAware
  def no_conflict?(existing_range, new_range)
    !range_conflict_either_end?(existing_range, new_range)
  end

  def range_conflict?(range, time)
    range.cover?(time)
  end

  def range_conflict_both_ends?(range1, range2)
    range_conflict?(range1, range2.first) && range_conflict?(range1, range2.last)
  end

  def range_conflict_either_end?(range1, range2)
    range_conflict?(range1, range2.first) || range_conflict?(range1, range2.last)
  end
end
