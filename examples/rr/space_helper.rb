module RR
describe Space, :shared => true do
  after(:each) do
    Space.instance.verify_scenarios
  end
end
end
