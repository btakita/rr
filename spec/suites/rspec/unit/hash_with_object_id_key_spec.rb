require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module RR
  describe HashWithObjectIdKey do
    describe "#[] and #[]=" do
      it "stores object via object id" do
        hash = HashWithObjectIdKey.new
        array_1 = []
        hash[array_1] = 1
        array_2 = []
        hash[array_2] = 2

        expect(hash[array_1]).to_not eq hash[array_2]
      end

      it "stores the passed in object" do
        hash = HashWithObjectIdKey.new
        obj = Object.new
        hash[obj] = 1
        expect(hash.instance_eval {@keys}).to eq({obj.__id__ => obj})
      end
    end

    describe "#each" do
      it "iterates through the items in the hash" do
        hash = HashWithObjectIdKey.new
        hash['one'] = 1
        hash['two'] = 2

        keys = []
        values = []
        hash.each do |key, value|
          keys << key
          values << value
        end

        expect(keys.sort).to eq ['one', 'two']
        expect(values.sort).to eq [1, 2]
      end
    end

    describe "#delete" do
      before do
        @hash = HashWithObjectIdKey.new
        @key = Object.new
        @hash[@key] = 1
      end

      it "removes the object from the hash" do
        @hash.delete(@key)
        expect(@hash[@key]).to be_nil
      end

      it "removes the object from the keys hash" do
        @hash.delete(@key)
        expect(@hash.instance_eval { @keys }).to eq({})
      end
    end

    describe "#keys" do
      before do
        @hash = HashWithObjectIdKey.new
        @key = Object.new
        @hash[@key] = 1
      end

      it "returns an array of the keys" do
        expect(@hash.keys).to eq [@key]
      end
    end

    describe "#include?" do
      before do
        @hash = HashWithObjectIdKey.new
        @key = Object.new
        @hash[@key] = 1
      end

      it "returns true when the key is in the Hash" do
        expect(@hash.include?(@key)).to be_true
      end

      it "returns false when the key is not in the Hash" do
        expect(@hash.include?(Object.new)).to be_false
      end
    end
  end
end
