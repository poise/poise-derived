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

require 'serverspec'
set :backend, :exec

# Test data to check.
{
  'a' => 'a',
  'b' => 'b',
  'c' => '1',
  'd' => 'd',
  'e' => '1 2',
  'f' => '2',
  'g' => '2',
  'h' => 'two 2',
  'i' => 'two one 1 2',
}.each do |test, value|
  describe file("/test/#{test}") do
    its(:content) { is_expected.to eq value }
  end
end
