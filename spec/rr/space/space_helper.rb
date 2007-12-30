module RR
  describe Space, :shared => true do
    after(:each) do
      Space.instance.verify_double_insertions
    end
  end
end
