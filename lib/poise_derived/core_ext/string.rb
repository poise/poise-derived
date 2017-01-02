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

require 'poise_derived/lazy_attribute'


# Monkeypatch String so that our magic works in case statements. If you're
# reading this, something has probably gone wrong. I'm so sorry.
#
# @since 1.0.0
# @api private
class String
  old_method = method(:===)
  define_singleton_method(:===) do |obj|
    if obj.class <= ::PoiseDerived::LazyAttribute
      true
    else
      old_method.call(obj)
    end
  end
end

