# Used by specs which delete a photo or guess to assert that the owner had no
# other photos or other guesses, so they should have been deleted too.
# It would be nice to mock the method that deletes the owner, which handles
# cases where the owner has a photo or other guess and shouldn't be deleted,
# but doing so would be ugly.
def owner_does_not_exist(owner)
  Person.exists?(owner.person.id).should == false
end
