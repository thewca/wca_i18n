RSpec.describe WcaI18n::YAMLWithComments do
  let(:yml) {
    "# Leading comment
      en:
        # this is a
        #
        # multiline comment
        foo: bar
        fiz: buzz

        # these are all the people
        people:
          joe:
            # So old!
            age: 4000
          e:
            # So young!
            age: 4
    "
  }

  it "#parse_yml_with_comments includes comments" do
    expect(WcaI18n::YAMLWithComments.parse(yml)).to eq(WcaI18n::YAMLWithComments.new("", {
      "en" => WcaI18n::YAMLWithComments.new("Leading comment", {
        "foo" => WcaI18n::YAMLWithComments.new("this is a\nmultiline comment", "bar"),
        "fiz" => WcaI18n::YAMLWithComments.new("", "buzz"),
        "people" => WcaI18n::YAMLWithComments.new("these are all the people", {
          "joe" => WcaI18n::YAMLWithComments.new("", {
            "age" => WcaI18n::YAMLWithComments.new("So old!", 4000),
          }),
          "e" => WcaI18n::YAMLWithComments.new("", {
            "age" => WcaI18n::YAMLWithComments.new("So young!", 4),
          }),
        }),
      }),
    }))
  end

  it "#strip_comments removes comments" do
    expect(WcaI18n::YAMLWithComments.parse(yml).strip_comments).to eq({
      "en" => {
        "foo" => "bar",
        "fiz" => "buzz",
        "people" => {
          "joe" => {
            "age" => 4000,
          },
          "e" => {
            "age" => 4,
          },
        }
      }
    })
  end
end
