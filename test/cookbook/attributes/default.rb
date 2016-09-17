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

# Baseline for sanity.
default['a']['value'] = 'a'

default['b']['value'] = lazy 'b'

default['c']['one'] = '1'
default['c']['value'] = lazy '%{c.one}'

default['d']['value'] = lazy { 'd' }

default['e']['one'] = 1
default['e']['two'] = '2'
default['e']['value'] = lazy '%{e.one} %{e.two}'

# This value is changed later.
default['f']['one'] = '1'
default['f']['value'] = lazy '%{f.one}'

# This value is changed later.
default['g']['one'] = '1'
default['g']['value'] = lazy { node['g']['one'] }
