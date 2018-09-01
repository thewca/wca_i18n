RSpec.describe WcaI18n::YAMLToEnrichedRubyHash do
  let(:yml) {
    "# Leading comment
      en:
        # this is a
        #
        # multiline comment without hash
        foo: bar
        #original_hash: abc
        fiz: buzz

        # these are all the people
        #original_hash: def
        people:
          # this is a pluralized key
          #original_hash: plural
          stuff:
            one: One
            two: 2
            many: a lot
          joe:
            # So old!
            # original_hash: wrongly formated original hash
            age: 4000
          e:
            # So young!
            #original_hash: 123
            age: 4
    "
  }

  it "#parse_yml_with_original_hashes includes original hashes" do
    # This makes sure that only leaves gets turned into TranslatedLeaf,
    # and that pluralization are handled appropriately (ie: the whole map is considered a leaf).
    expect(WcaI18n::YAMLToEnrichedRubyHash.parse(yml)).to eq({
      "en" => {
        "foo" => WcaI18n::TranslatedLeaf.new("bar", nil),
        "fiz" => WcaI18n::TranslatedLeaf.new("buzz", "abc"),
        "people" => {
          "stuff" => WcaI18n::TranslatedLeaf.new({
            "one" => "One",
            "two" => 2,
            "many" => "a lot",
          }, "plural"),
          "joe" => {
            "age" => WcaI18n::TranslatedLeaf.new(4000, nil),
          },
          "e" => {
            "age" => WcaI18n::TranslatedLeaf.new(4, "123"),
          },
        },
      },
    })
  end
end
