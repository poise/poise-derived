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

require 'chef/chef_class'
require 'chef/event_dispatch/base'

require 'poise_derived/dsl'


module PoiseDerived
  # A small event handler to install and uninstall our DSL addition so it only
  # appears during attribute compilation. Is this a good idea?
  #
  # @api private
  class Handler < Chef::EventDispatch::Base
    include Singleton

    def attribute_load_start(count)
      PoiseDerived::DSL.install
    end

    def attribute_load_complete
      PoiseDerived::DSL.uninstall
    end

    # Install event handler.
    Chef::Log.debug('[poise-derived] Installing event handler')
    Chef.run_context.events.register(self.instance)
  end
end
