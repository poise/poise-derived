#
# Copyright 2016-2017, Noah Kantrowitz
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

require 'chef/node/attribute'
require 'chef/mixin/deep_merge'

require 'poise_derived/lazy_attribute'


module PoiseDerived
  module CoreExt
    # Monkey-patch deep merge to carry over LazyAttribute on override. This means
    # that if a lazy is set in a cookbook and then that attribute is overridden
    # in a role or another cookbook, the override value gets wrapped in a
    # LazyAttribute too so it will act as a template string. There is no way to
    # put a block in JSON data so that would have to be explicit.
    #
    # @since 1.0.0
    # @api private
    module DeepMerge
      def deep_merge!(source, dest)
        if source.is_a?(PoiseDerived::LazyAttribute) && dest.is_a?(String)
          source._override(dest)
        else
          super
        end
      end

      def hash_only_merge!(merge_onto, merge_with)
        if merge_onto.is_a?(PoiseDerived::LazyAttribute) && merge_with.is_a?(String)
          merge_onto._override(merge_with)
        else
          super
        end
      end

      # Kinder, gentler monkey patching. The singleton_class is the important
      # one since everything in Chef calls these as module methods.
      Chef::Mixin::DeepMerge.prepend(self)
      Chef::Mixin::DeepMerge.singleton_class.prepend(self)

      # Later versions of Chef implement these directly in the Chef::Node::Attribute
      # class, so patch those too if needed.
      Chef::Node::Attribute.prepend(self) if Chef::Node::Attribute.private_instance_methods(false).include?(:deep_merge!)
    end
  end
end
