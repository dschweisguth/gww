module UpdatableOnlyIfNecessary

  # Update attributes only if any have changed. update_attributes! doesn't issue an update if no attributes have
  # changed, but it does start a transaction, which is slow.
  def update_attributes_if_necessary!(attrs)
    if attrs.any? { |attr| attr[1] != self[attr[0]] }
      update_attributes! attrs
    end
  end

end
