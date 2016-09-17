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

require 'poise_derived/lazy_attribute'

module PoiseDerived
  module CoreExt
    # Holding module for the one value I need. Also yay consistency.
    #
    # @since 1.0.0
    # @api private
    module Module
      # Used below to fake Module#===
      EMPTY_STRING = ''.freeze
    end
  end
end

class Module
  old_method = instance_method(:===)
  define_method(:===) do |obj|
    orig = old_method.bind(self).call(obj)
    if obj.class <= PoiseDerived::LazyAttribute
      orig || self === PoiseDerived::CoreExt::Module::EMPTY_STRING
    else
      orig
    end
  end
end
