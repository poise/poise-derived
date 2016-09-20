#
# Copyright 2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe PoiseDerived::LazyAttribute do
  subject { chef_run.node['url'] }

  describe '#to_s' do
    subject { chef_run.node['url'].to_s }

    context 'with a string' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
      end

      it { is_expected.to eq 'https://example.com/1.0.0' }
    end # /context with a string

    context 'with a block' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node)  { "https://example.com/#{node['version']}" }
      end

      it { is_expected.to eq 'https://example.com/1.0.0' }
    end # /context with a block
  end # /describe #to_s

  describe '#inspect' do
    subject { chef_run.node['url'].inspect }

    context 'with a string' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
      end

      it { is_expected.to eq '#<PoiseDerived::LazyAttribute @value="https://example.com/%{version}">' }
    end # /context with a string

    context 'with a block' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node)  { "https://example.com/#{node['version']}" }
      end

      it { is_expected.to eq '#<PoiseDerived::LazyAttribute @value=proc>' }
    end # /context with a block
  end # /describe #inspect

  describe 'evaluation' do
    context 'with no arguments' do
      subject { described_class.new(nil) }

      it { expect { subject }.to raise_error ArgumentError }
    end # /context with no arguments

    context 'with both arguments' do
      subject { described_class.new(nil, '') { } }

      it { expect { subject }.to raise_error ArgumentError }
    end # /context with both arguments

    context 'with a single replacement' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
      end

      it { is_expected.to eq 'https://example.com/1.0.0' }
    end # /context with a single replacement

    context 'with a two replacements' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['type'] = 'zip'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}.%{type}')
      end

      it { is_expected.to eq 'https://example.com/1.0.0.zip' }
    end # /context with a two replacements

    context 'with a nested replacement' do
      subject { chef_run.node['myapp']['url'] }
      recipe(subject: false) do
        node.default['myapp']['version'] = '1.0.0'
        node.default['myapp']['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{myapp.version}')
      end

      it { is_expected.to eq 'https://example.com/1.0.0' }
    end # /context with a nested replacement

    context 'with an overridden replacement' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
        node.override['version'] = '2.0.0'
      end

      it { is_expected.to eq 'https://example.com/2.0.0' }
    end # /context with an overridden replacement

    context 'with an overriden template' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
        node.override['url'] = 'https://example.net/%{version}'
      end

      it { is_expected.to eq 'https://example.net/1.0.0' }
    end # /context with an overriden template

    context 'with a block' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url'] = PoiseDerived::LazyAttribute.new(node) { "https://example.com/#{node['version']}" }
      end

      it { is_expected.to eq 'https://example.com/1.0.0' }
    end # /context with a block

    context 'with a double-lazy chain' do
      recipe(subject: false) do
        node.default['version'] = '1.0.0'
        node.default['url_part'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
        node.default['url'] = PoiseDerived::LazyAttribute.new(node, '%{url_part}.zip')
      end

      it { is_expected.to eq 'https://example.com/1.0.0.zip' }
    end # /context with a double-lazy chain
  end #/ describe evaluation

  describe 'use in a resource' do
    recipe do
      node.default['content'] = PoiseDerived::LazyAttribute.new(node, 'content')
      file '/test' do
        content node['content']
      end
    end

    it { is_expected.to render_file('/test').with_content('content') }
  end # /describe use in a resource
end
