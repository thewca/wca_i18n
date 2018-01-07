RSpec.describe WcaI18n::YamlWithComments do
  it "#parse_yml_with_comments includes comments" do
    yml = "
      en:
        # this is a
        # multiline comment
        foo: bar
        fiz: buzz

        # these are all the people
        subtree:
          age: 4000
    "
    expect(WcaI18n::YamlWithComments.parse(yml)).to eq(WcaI18n::YamlWithComments::CommentedValue.new("", {
      "en" => WcaI18n::YamlWithComments::CommentedValue.new("", {
        "foo" => WcaI18n::YamlWithComments::CommentedValue.new("this is a\nmultiline comment", "bar"),
        "fiz" => WcaI18n::YamlWithComments::CommentedValue.new("", "buzz"),
        "subtree" => WcaI18n::YamlWithComments::CommentedValue.new("these are all the people", {
          "age" => WcaI18n::YamlWithComments::CommentedValue.new("", 4000),
        }),
      }),
    }))
  end
end
