RSpec.describe WcaI18n::Translation do
  context "#compare_to" do
    it "detects missing, unused, and outdated translations" do
      base = WcaI18n::Translation.new("en", "
        en:
          feature:
            happy: Happy
            star: Star
            new: Very new feature

          super_new_feature:
            0: zero
            a: A
      ")
      translation = WcaI18n::Translation.new("es", "
        es:
          feature:
            # This translation is up to date.
            #original_hash: #{WcaI18n::Translation.hash_translation("Happy")}
            happy: Contento

            # This translation is outdated.
            #original_hash: sooo_old
            star: Estrella

            # This translation is unused.
            old: Viejo

          removed_feature:
            a: A
            b: B
      ")

      expect(translation.compare_to(base)).to eq({
        missing: [ %w(feature new), ["super_new_feature", 0], %w(super_new_feature a) ],
        unused: [ %w(feature old), %w(removed_feature a), %w(removed_feature b) ],
        outdated: [ %w(feature star) ],
      })
    end

    it "handles a string that changed into a tree" do
      base = WcaI18n::Translation.new("en", "
        en:
          i_became_a_tree:
            foo: bar
      ")
      translation = WcaI18n::Translation.new("es", "
        es:
          i_became_a_tree: but i was once a string
      ")

      expect(translation.compare_to(base)).to eq({
        missing: [ %w(i_became_a_tree foo) ],
        unused: [ %w(i_became_a_tree) ],
        outdated: [],
      })
    end

    it "handles a tree that changed into a string" do
      base = WcaI18n::Translation.new("en", "
        en:
          i_was_once_a_tree: but now i am a string
      ")
      translation = WcaI18n::Translation.new("es", "
        es:
          i_was_once_a_tree:
            see: i am a tree
      ")

      expect(translation.compare_to(base)).to eq({
        missing: [ %w(i_was_once_a_tree) ],
        unused: [ %w(i_was_once_a_tree see) ],
        outdated: [],
      })
    end

    context "pluralization" do
      it "detects when up to date" do
        base = WcaI18n::Translation.new("en", "
          en:
            #context: Words used to describe combined round cutoffs
            cutoff:
              time:
                one: '%{count} attempt to get < %{time}'
                other: '%{count} attempts to get < %{time}'
        ")
        translation = WcaI18n::Translation.new("da", "
          da:
            cutoff:
              #original_hash: cf458e7
              time:
                zero: '%{count} prøver at få < %{time}'
                one: '%{count} prøver at få < %{time}'
                other: '%{count} prøver at få < %{time}'
        ")

        expect(translation.compare_to(base)).to eq({
          missing: [],
          unused: [],
          outdated: [],
        })
      end

      it "detects when out of date" do
        base = WcaI18n::Translation.new("en", "
          en:
            #context: Words used to describe combined round cutoffs
            cutoff:
              time:
                one: '%{count} attempt to get < %{time}'
                other: '%{count} attempts to get < %{time}'
        ")
        translation = WcaI18n::Translation.new("da", "
          da:
            cutoff:
              #original_hash: this_is_wrong
              time:
                zero: '%{count} prøver at få < %{time}'
                one: '%{count} prøver at få < %{time}'
                other: '%{count} prøver at få < %{time}'
        ")

        expect(translation.compare_to(base)).to eq({
          missing: [],
          unused: [],
          outdated: [ %w(cutoff time) ],
        })
      end

      it "detects missing" do
        base = WcaI18n::Translation.new("en", "
          en:
            #context: Words used to describe combined round cutoffs
            cutoff:
              time:
                one: '%{count} attempt to get < %{time}'
                other: '%{count} attempts to get < %{time}'
        ")
        translation = WcaI18n::Translation.new("da", "
          da: {}
        ")

        expect(translation.compare_to(base)).to eq({
          missing: [ %w(cutoff time) ],
          unused: [],
          outdated: [],
        })
      end

      it "detects unused" do
        base = WcaI18n::Translation.new("en", "
          en: {}
        ")
        translation = WcaI18n::Translation.new("da", "
          da:
            cutoff:
              #original_hash: this_is_wrong
              time:
                zero: '%{count} prøver at få < %{time}'
                one: '%{count} prøver at få < %{time}'
                other: '%{count} prøver at få < %{time}'
        ")

        expect(translation.compare_to(base)).to eq({
          missing: [],
          unused: [ %w(cutoff time) ],
          outdated: [],
        })
      end
    end
  end
end
