RSpec.describe WcaI18n::Translation do
  context "#compare_to" do
    it "detects missing, unused, and outdated translations" do
      en = WcaI18n::Translation.new("en", "
        en:
          feature:
            happy: Happy
            star: Star
            new: Very new feature

          super_new_feature:
            0: zero
            a: A
      ")
      es = WcaI18n::Translation.new("es", "
        es:
          feature:
            # This translation is up to date.
            # original_hash: #{WcaI18n::Translation.hash_translation("Happy")}
            happy: Contento

            # This translation is outdated.
            # original_hash: sooo_old
            star: Estrella

            # This translation is unused.
            old: Viejo

          removed_feature:
            a: A
            b: B
      ")

      expect(es.compare_to(en)).to eq({
        missing: [ %w(feature new), ["super_new_feature", 0], %w(super_new_feature a) ],
        unused: [ %w(feature old), %w(removed_feature a), %w(removed_feature b) ],
        outdated: [ %w(feature star) ],
      })
    end

    it "handles a string that changed into a tree" do
      en = WcaI18n::Translation.new("en", "
        en:
          i_became_a_tree:
            foo: bar
      ")
      es = WcaI18n::Translation.new("es", "
        es:
          i_became_a_tree: but i was once a string
      ")

      expect(es.compare_to(en)).to eq({
        missing: [ %w(i_became_a_tree foo) ],
        unused: [ %w(i_became_a_tree) ],
        outdated: [],
      })
    end

    it "handles a tree that changed into a string" do
      en = WcaI18n::Translation.new("en", "
        en:
          i_was_once_a_tree: but now i am a string
      ")
      es = WcaI18n::Translation.new("es", "
        es:
          i_was_once_a_tree:
            see: i am a tree
      ")

      expect(es.compare_to(en)).to eq({
        missing: [ %w(i_was_once_a_tree) ],
        unused: [ %w(i_was_once_a_tree see) ],
        outdated: [],
      })
    end
  end
end
