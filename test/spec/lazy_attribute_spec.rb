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
  context 'with a single replacement' do
    recipe do
      node.default['version'] = '1.0.0'
      node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
      file '/test' do
        content node['url']
      end
    end

    it { is_expected.to render_file('/test').with_content('https://example.com/1.0.0') }
  end # /context with a single replacement

  context 'with a two replacements' do
    recipe do
      node.default['version'] = '1.0.0'
      node.default['type'] = 'zip'
      node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}.%{type}')
      file '/test' do
        content node['url']
      end
    end

    it { is_expected.to render_file('/test').with_content('https://example.com/1.0.0.zip') }
  end # /context with a two replacements

  context 'with a nested replacement' do
    recipe do
      node.default['myapp']['version'] = '1.0.0'
      node.default['myapp']['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{myapp.version}')
      file '/test' do
        content node['myapp']['url']
      end
    end

    it { is_expected.to render_file('/test').with_content('https://example.com/1.0.0') }
  end # /context with a nested replacement

  context 'with an overridden replacement' do
    recipe do
      node.default['version'] = '1.0.0'
      node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
      node.override['version'] = '2.0.0'
      file '/test' do
        content node['url']
      end
    end

    it { is_expected.to render_file('/test').with_content('https://example.com/2.0.0') }
  end # /context with an overridden replacement

  context 'with an overriden template' do
    recipe do
      node.default['version'] = '1.0.0'
      node.default['url'] = PoiseDerived::LazyAttribute.new(node, 'https://example.com/%{version}')
      node.override['url'] = 'https://example.net/%{version}'
      file '/test' do
        content node['url']
      end
    end

    it { is_expected.to render_file('/test').with_content('https://example.net/1.0.0') }
  end # /context with an overriden template

  context 'with a block' do
    recipe do
      node.default['version'] = '1.0.0'
      node.default['url'] = PoiseDerived::LazyAttribute.new(node) { "https://example.com/#{node['version']}" }
      file '/test' do
        content node['url']
      end
    end

    it { is_expected.to render_file('/test').with_content('https://example.com/1.0.0') }
  end # /context with a block
end
