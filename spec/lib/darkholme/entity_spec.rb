require 'spec_helper'

module Darkholme
  describe Entity do
    subject { MockEntity.new }
    let(:engine) { Engine.new }
    let(:system) { MockSystem.new }
    let(:component) { MockComponent.new }

    describe "with callbacks" do
      it "sets self.engine when added to an engine" do
        subject.added_to_engine(engine)

        expect(subject.engine).to eq(engine)
      end

      it "clears self.engine when removed from an engine" do
        subject.engine = engine
        expect(subject.engine).to eq(engine)
        subject.removed_from_engine(engine)

        expect(subject.engine).to be_nil
      end
    end

    describe "with components" do
      describe "adding one" do
        it "makes has_component? return true" do
          subject.add_component(component)
          expect(subject.has_component?(component.class)).to eq(true)
        end

        it "returns the component" do
          added = subject.add_component(component)
          expect(added).to eq(component)
        end

        it "sets the associated component bit" do
          bits = subject.component_bits
          expect(bits).to receive(:set).with(component.bit)

          subject.add_component(component)
        end

        it "notifies the engine" do
          subject.engine = Engine.new
          expect(subject.engine).to receive(:component_added).with(
            subject, component
          )

          subject.add_component(component)
        end
      end

      describe "removing one" do
        let!(:added) { subject.add_component(component) }

        it "makes has_component? return false" do
          subject.remove_component(component.class)
          expect(subject.has_component?(component.class)).to eq(false)
        end

        it "returns the component" do
          removed = subject.remove_component(component.class)
          expect(removed).to eq(component)
        end

        it "clears the associated component bit" do
          bits = subject.component_bits
          expect(bits).to receive(:clear).with(component.bit)

          subject.remove_component(component.class)
        end

        it "notifies the engine" do
          subject.engine = Engine.new
          expect(subject.engine).to receive(:component_removed).with(
            subject, component
          )

          subject.remove_component(component.class)
        end
      end

      it "returns a component instance when asked for one" do
        subject.add_component(component)
        expect(subject.component_for(component.class)).to be_a MockComponent
      end
    end

    it "can be created from a JSON manifest" do
      entity = Entity.load(entity_json)
      expect(entity.has_component? MockComponent).to eq(true)
    end

    private

    def entity_json
      <<-JSON
{
  "components": {
    "MockComponent": {}
  }
}
      JSON
    end
  end
end
