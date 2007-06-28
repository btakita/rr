module RR
describe Space, :shared => true do
  after(:each) do
    Space.instance.verify_doubles
  end
end
end
