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


module PoiseDerived
  # A class to lazily evaluate node attributes either from format strings or
  # code blocks.
  #
  # @example Cookbook attributes file
  #   default['mycookbook']['version'] = '1.0'
  #   default['mycookbook']['url'] = lazy 'https://example.com/myapp-%{mycookbook.version}.zip'
  class LazyAttribute
    # Parser regexp for format strings.
    # @api private
    FORMAT_STRING_REGEXP = /%\{([^}]+)\}/

    def initialize(node, str=nil, &block)
      unless (!!str) ^ (!!block)
       raise ArgumentError.new('Either a string or block must be passed when creating a lazy attribute')
      end
      @node = node
      @value = str || block
    end

    # Shorter inspect output for debugging so we don't vomit the node into the
    # log or spec output.
    #
    # @return [String]
    def inspect
      if @value.is_a?(Proc)
        "#<#{self.class.name} @value=proc>"
      else
        "#<#{self.class.name} @value=#{@value.inspect}>"
      end
    end

    # Return a copy of this attribute with the same node context but an
    # override value as the format string. This can't support blocks because of
    # how it is called generally.
    #
    # @api private
    # @see PoiseDerived::CoreExt
    # @return [PoiseDerived::LazyAttribute]
    def _override(str)
      self.class.new(@node, str)
    end

    # @!group delegators
    # Delegate to the lazy value.
    # @api private
    def method_missing(method, *args, &block)
      _evaluate.send(method, *args, &block)
    end

    # Delegate to the lazy value.
    # @api private
    def respond_to_missing?(method, include_all)
      _evaluate.respond_to?(method, include_all)
    end

    # Delegate to the lazy value.
    # @api private
    def to_s
      _evaluate.to_s
    end

    # Make sure we implement to_str because that activates the == hack.
    # @api private
    def to_str
      to_s
    end

    # Fake is_a? and kind_of? for params_validate and `_pv_kind_of`.
    # @api private
    def is_a?(klass)
      return true if Object.instance_method(:is_a?).bind(self).call(klass)
      klass <= String
    end

    # @api private
    # @see is_a?
    alias_method :kind_of?, :is_a?

    # Specifically delegate == because not caught by method_missing.
    # @api private
    def ==(other)
      _evaluate == other
    end
    # !@endgroup

    # Don't actually freeze because Chef 13 freezes values in the merged
    # attribute view.
    # @api private
    def freeze
     self
    end

    private

    # Evaluate the lazy attribute.
    #
    # @return [Object]
    def _evaluate
      return @evaluate_cache if defined?(@evaluate_cache)
      @evaluate_cache = if @value.is_a?(Proc)
        # Block mode, just run the block.
        @node.instance_eval(&@value).to_s
      else
        # String mode, parse the template string and fill it in.
        format_keys = @value.scan(FORMAT_STRING_REGEXP).inject({}) do |memo, (key)|
          # Keys must be symbols because Ruby.
          memo[key.to_sym] = key.split(/\./).inject(@node) {|n, k| n.nil? ? n : n[k] }
          memo
        end
        @value % format_keys
      end
    end
  end
end
