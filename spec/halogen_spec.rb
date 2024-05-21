describe Halogen do
  let(:klass) { Class.new { include Halogen } }

  describe Halogen::ClassMethods do
    describe '#resource' do
      it 'includes resource module' do
        expect(klass).to receive(:define_resource)
        klass.resource :foo
        expect(klass.included_modules).to include(Halogen::Resource)
      end
    end

    describe '#collection' do
      it 'includes collection module' do
        expect(klass).to receive(:define_collection)
        klass.collection :foo
        expect(klass.included_modules).to include(Halogen::Collection)
      end
    end

    describe '#collection?' do
      it 'is false by default' do
        expect(klass.collection?).to eq(false)
      end

      it 'is true for collection' do
        klass.collection :foo
        expect(klass.collection?).to eq(true)
      end
    end
  end

  describe Halogen::InstanceMethods do
    let(:instance) { klass.new }

    describe '#initialize' do
      it 'symbolizes option keys' do
        repr = klass.new('embed' => { 'foo' => 'bar' }, 'ignore' => 'this', :convert => 'that')
        expect(repr.options).to eq(embed: { 'foo' => 'bar' }, ignore: 'this', convert: 'that')
      end
    end

    describe '#render' do
      let(:rendered) { instance.render }

      it 'renders simple link' do
        klass.link(:label) { 'href' }
        expect(rendered[:_links][:label]).to eq(href: 'href')
      end

      it 'excludes links with failing conditions' do
        [:return_false, :return_nil].each { |m| klass.define_method(m) { send(m) == :return_false ? false : nil } }
        klass.link(:label) { 'href' }
        %i[label_2 label_3 label_4 label_5].each { |label| klass.link(label, if: false) { 'href' } }
        expect(rendered[:_links].keys).to eq([:label])
      end

      it 'includes links with passing conditions' do
        [:return_true, :return_one].each { |m| klass.define_method(m) { send(m) == :return_true ? true : 1 } }
        klass.link(:label) { 'href' }
        %i[label_2 label_3 label_4 label_5].each { |label| klass.link(label, if: true) { 'href' } }
        expect(rendered[:_links].keys).to match_array([:label, :label_2, :label_3, :label_4, :label_5])
      end
    end

    describe '#depth' do
      it 'is zero for top level representer' do
        expect(instance.depth).to eq(0)
      end

      it 'has expected value for embedded children' do
        child, grandchild = [instance, instance].map { klass.new }
        allow(child).to receive(:parent).and_return(instance)
        allow(grandchild).to receive(:parent).and_return(child)
        expect(instance.depth).to eq(0)
        expect(child.depth).to eq(1)
        expect(grandchild.depth).to eq(2)
      end
    end

    describe '#to_json' do
      it 'converts rendered representer to json' do
        expect(instance.to_json).to eq('{}')
      end
    end
  end

  describe '.config' do
    it 'yields configuration instance' do
      Halogen.configure do |config|
        expect(config).to eq(Halogen.config)
      end
    end
  end
end
