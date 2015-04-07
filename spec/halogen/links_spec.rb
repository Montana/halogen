# encoding: utf-8
#
require 'spec_helper'

describe Halogen::Links do
  let :klass do
    Class.new { include Halogen }
  end

  describe Halogen::Links::ClassMethods do
    describe '#link' do
      describe 'with procedure' do
        it 'builds simple definition' do
          link = klass.link(:self) { 'path' }

          expect(link.name).to eq(:self)
          expect(link.options).to eq(attrs: {})
          expect(link.procedure.call).to eq('path')
        end

        it 'builds complex definition' do
          link = klass.link(
            :self, :templated, foo: 'foo', attrs: { bar: 'bar' }) { 'path' }

          expect(link.name).to eq(:self)
          expect(link.options).to eq(
            foo: 'foo', attrs: { templated: true, bar: 'bar' })
          expect(link.procedure.call).to eq('path')
        end

        it 'handles multiple values' do
          klass.link(:self) { %w(foo bar) }

          rendered = klass.new.render[:_links][:self]

          expect(rendered).to eq([{ href: 'foo' }, { href: 'bar' }])
        end
      end

      describe 'without procedure' do
        describe 'with explicit value' do
          it 'builds simple definition' do
            link = klass.link(:self, value: 'path')

            expect(link.name).to eq(:self)
            expect(link.options).to eq(attrs: {}, value: 'path')
            expect(link.procedure).to be_nil
          end

          it 'builds complex definition' do
            link = klass.link(
              :self,
              :templated,
              foo: 'foo', attrs: { bar: 'bar' }, value: 'path')

            expect(link.name).to eq(:self)
            expect(link.options).to eq(
              foo: 'foo',
              attrs: { templated: true, bar: 'bar' },
              value: 'path')
            expect(link.procedure).to be_nil
          end
        end
      end
    end
  end
end
