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

# Late override of some values.
node.override['f']['one'] = '2'
node.override['g']['one'] = '2'
node.override['h']['value'] = 'two %{h.two}'

directory '/test'

('a'..'i').each do |test|
  file "/test/#{test}" do
    content node[test]['value']
  end
end
